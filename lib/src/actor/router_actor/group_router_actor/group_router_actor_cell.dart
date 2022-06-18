part of theater.actor;

class GroupRouterActorCell extends RouterActorCell<GroupRouterActor>
    with UserActorCellMixin<GroupRouterActor> {
  GroupRouterActorCell(
      ActorPath path,
      GroupRouterActor actor,
      LocalActorRef parentRef,
      SendPort actorSystemSendPort,
      LoggingProperties loggingProperties,
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
        actor,
        GroupRouterActorProperties(
            actorRef: ref,
            parentRef: parentRef,
            handlingType: _mailbox.handlingType,
            deployementStrategy: actor.createDeployementStrategy(),
            supervisorStrategy: actor.createSupervisorStrategy(),
            mailboxType: _mailbox.type,
            actorSystemSendPort: _actorSystemSendPort,
            loggingProperties: ActorLoggingProperties.fromLoggingProperties(
                loggingProperties, actor.createLoggingPropeties()),
            data: data),
        RouterActorIsolateHandlerFactory(),
        GroupRouterActorContextBuilder(), onError: (error) {
      _errorController.sink
          .add(ActorError(path, error.object, error.stackTrace));
    });

    _isolateSupervisor.messages.listen(_handleMessageFromIsolate);

    _mailbox.actorRoutingMessages.listen((message) {
      _isolateSupervisor.send(message);
    });

    _mailbox.mailboxMessages.listen((message) {
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
              message: 'Untyped escalate error from [' +
                  event.error.path.toString() +
                  '].'),
          StackTrace.current,
          parent: event.error));
    }
  }
}
