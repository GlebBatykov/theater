part of theater.actor;

class SystemActorCell extends NodeActorCell<SystemActor> {
  SystemActorCell(ActorPath path, SystemActor actor, LocalActorRef parentRef,
      SendPort actorSystemSendPort, LoggingProperties loggingProperties,
      {Map<String, dynamic>? data,
      void Function(ActorError)? onError,
      void Function()? onKill})
      : super(
            path,
            actor,
            parentRef,
            actor.createMailboxFactory().create(MailboxProperties(path)),
            actorSystemSendPort,
            loggingProperties,
            onKill) {
    if (onError != null) {
      _errorController.stream.listen(onError);
    }

    ref = LocalActorRef(path, _mailbox.sendPort);

    _isolateSupervisor = IsolateSupervisor(
        _actor,
        SystemActorProperties(
            actor: _actor,
            actorRef: ref,
            parentRef: _parentRef,
            supervisorStrategy: actor.createSupervisorStrategy(),
            handlingType: _mailbox.handlingType,
            mailboxType: _mailbox.type,
            loggingProperties: ActorLoggingProperties.fromLoggingProperties(
                loggingProperties, actor.createLoggingPropeties()),
            actorSystemSendPort: _actorSystemSendPort,
            data: data),
        SystemActorIsolateHandlerFactory(),
        SystemActorContextBuilder(), onError: (error) {
      _errorController.sink
          .add(ActorError(path, error.object, error.stackTrace));
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

    _actorSystemSendPort.send(ActorSystemRegisterSystemLocalActorRef(ref));
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
          StackTrace.current,
          parent: event.error));
    }
  }

  @override
  Future<void> dispose() async {
    await super.dispose();

    _actorSystemSendPort.send(ActorSystemRemoveSystemLocalActorRef(path));
  }
}
