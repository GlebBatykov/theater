part of theater.actor;

class UntypedActorCell extends NodeActorCell<UntypedActor> {
  UntypedActorCell(ActorPath path, UntypedActor actor, LocalActorRef parentRef,
      {Map<String, dynamic>? data,
      void Function(ActorError)? onError,
      void Function()? onKill})
      : super(
            path,
            actor,
            parentRef,
            actor.createMailboxFactory().create(MailboxProperties(path)),
            onKill) {
    if (onError != null) {
      _errorController.stream.listen(onError);
    }

    ref = LocalActorRef(path, _mailbox.sendPort);

    _isolateSupervisor = IsolateSupervisor(
        _actor,
        UntypedActorProperties(
            actorRef: ref,
            parentRef: _parentRef,
            supervisorStrategy: actor.createSupervisorStrategy(),
            mailboxType: _mailbox.type,
            data: data),
        UntypedActorIsolateHandlerFactory(),
        UntypedActorContextFactory(), onError: (error) {
      _errorController.sink
          .add(ActorError(path, error.exception, error.stackTrace.toString()));
    });

    _isolateSupervisor.messages.listen(_handleMessageFromIsolate);

    _mailbox.mailboxMessages.listen((message) {
      _isolateSupervisor.send(message);
    });

    _mailbox.actorRoutingMessages.listen((message) {
      _isolateSupervisor.send(message);
    });

    _mailbox.systemRoutingMessages.listen((message) {
      _isolateSupervisor.send(message);
    });
  }

  void _handleMessageFromIsolate(message) {
    if (message is ActorEvent) {
      _handleActorEvent(message);
    }
  }

  void _handleActorEvent(ActorEvent event) {
    if (event is ActorReceivedMessage) {
      if (_mailbox is ReliableMailbox) {
        (_mailbox as ReliableMailbox).next();
      }
    } else if (event is ActorErrorEscalated) {
      _errorController.sink.add(ActorError(
          path,
          ActorChildException(
              message: 'Receive escalate error from [' +
                  event.error.path.toString() +
                  '].'),
          StackTrace.current.toString(),
          parent: event.error));
    }
  }
}
