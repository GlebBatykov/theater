part of theater.actor;

class RootActorContext<P extends RootActorProperties>
    extends SupervisorActorContext<P> with NodeActorRefFactory<P> {
  RootActorContext(IsolateContext isolateContext, P actorProperties)
      : super(isolateContext, actorProperties) {
    _isolateContext.messages.listen(_handleMessageFromSupervisor);

    _childErrorSubscription = _childErrorController.stream
        .listen((error) => _handleChildError(error));
  }

  void _handleMessageFromSupervisor(ActorMessage message) {
    if (message is RoutingMessage) {
      _handleRoutingMessage(message);
    }
  }

  @override
  void _handleRoutingMessage(RoutingMessage message) {
    if (message.recipientPath == _actorProperties.path) {
      if (message is ActorRoutingMessage) {
        _actorProperties.actorRef
            .sendMessage(MailboxMessage(message.data, message.feedbackPort));
      } else if (message is SystemRoutingMessage) {
        _handleSystemRoutingMessage(message);
      }
    } else {
      if (message.recipientPath.depthLevel > _actorProperties.path.depthLevel &&
          List.of(message.recipientPath.segments
                  .getRange(0, _actorProperties.path.segments.length))
              .equal(_actorProperties.path.segments)) {
        var isSended = false;

        for (var child in _children) {
          if (List.from(message.recipientPath.segments
                  .getRange(0, _actorProperties.path.segments.length + 1))
              .equal(child.path.segments)) {
            child.ref.sendMessage(message);
            isSended = true;
            break;
          }
        }

        if (!isSended) {
          message.notFound();
        }
      } else {
        _isolateContext.supervisorMessagePort.send(message);
      }
    }
  }

  void _handleSystemRoutingMessage(SystemRoutingMessage message) async {
    if (message.data is ActorCreateChild) {
      var action = message.data as ActorCreateChild;

      var ref = await actorOf(action.name, action.actor,
          data: action.data, onKill: action.onKill);

      message.sendResult(ref);
    }
  }
}
