part of theater.actor;

class RootActorContext extends SupervisorActorContext<RootActorProperties>
    with NodeActorRefFactoryMixin<RootActorProperties> {
  IsolateContext get isolateContext => _isolateContext;

  RootActorProperties get actorProperties => _actorProperties;

  RootActorContext(
      IsolateContext isolateContext, RootActorProperties actorProperties)
      : super(isolateContext, actorProperties) {
    _isolateContext.messages.listen(_handleMessageFromSupervisor);

    _childErrorSubscription = _childErrorController.stream
        .listen((error) => _handleChildError(error));
  }

  void _handleMessageFromSupervisor(Message message) {
    if (message is RoutingMessage) {
      _handleRoutingMessage(message);
    }
  }

  @override
  void _handleRoutingMessage(RoutingMessage message) {
    if (message.recipientPath == _actorProperties.path) {
      if (message is ActorRoutingMessage) {
        _actorProperties.actorRef.send(ActorMailboxMessage(message.data,
            feedbackPort: message.feedbackPort));
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
            child.ref.send(message);
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
}
