part of theater.actor;

/// The class used by [UntypedActor] to communicate with other actors in the actor system, receive messages from other actors.
class UntypedActorContext extends NodeActorContext<UntypedActorProperties>
    with
        NodeActorRefFactoryMixin,
        ActorMessageReceiverMixin,
        UserActorContextMixin<UntypedActorProperties> {
  UntypedActorContext(
      IsolateContext isolateContext, UntypedActorProperties actorProperties)
      : super(isolateContext, actorProperties) {
    _isolateContext.messages.listen(_handleMessageFromSupervisor);

    _childErrorSubscription = _childErrorController.stream
        .listen((error) => _handleChildError(error));
  }

  void _handleMessageFromSupervisor(Message message) {
    if (message is MailboxMessage) {
      _handleMailboxMessage(message);
    } else if (message is RoutingMessage) {
      _handleRoutingMessage(message);
    }
  }

  void _handleMailboxMessage(MailboxMessage message) {
    if (message is ActorMailboxMessage) {
      _handleActorMailboxMessage(message);
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
        _actorProperties.parentRef.send(message);
      }
    }
  }
}
