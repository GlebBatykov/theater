part of theater.actor;

class RootActorCell extends SupervisorActorCell<RootActor> {
  RootActorCell(
      ActorPath path, RootActor actor, SendPort actorSystemMessagePort,
      {Map<String, dynamic>? data,
      void Function(ActorError)? onError,
      void Function()? onKill})
      : super(
            path,
            actor,
            actor.createMailboxFactory().create(MailboxProperties(path)),
            actorSystemMessagePort,
            onKill) {
    if (onError != null) {
      _errorController.stream.listen(onError);
    }

    ref = LocalActorRef(path, _mailbox.sendPort);

    _isolateSupervisor = IsolateSupervisor(
        _actor,
        RootActorProperties(
            actorRef: ref,
            supervisorStrategy: actor.createSupervisorStrategy(),
            mailboxType: _mailbox.type,
            actorSystemMessagePort: _actorSystemMessagePort,
            data: data),
        RootActorIsolateHandlerFactory(),
        RootActorContextBuilder());

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
    if (message is RoutingMessage) {
      _messageController.sink.add(message);
    } else if (message is ActorEvent) {
      _handleActorEvent(message);
    }
  }

  void _handleActorEvent(ActorEvent event) {
    if (event is ActorReceivedMessage) {
      if (_mailbox is ReliableMailbox) {
        (_mailbox as ReliableMailbox).next();
      }
    } else if (event is ActorErrorEscalated) {
      _errorController.sink.add(event.error);
    }
  }
}
