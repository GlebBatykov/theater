part of theater.actor;

/// The class used by [WorkerActor] to communicate with other actors in the actor system, receive messages from other actors.
class WorkerActorContext<P extends WorkerActorProperties>
    extends SheetActorContext<P>
    with UserActorContextMixin, ActorMessageReceiverMixin {
  WorkerActorContext(IsolateContext isolateContext, P actorProperties)
      : super(isolateContext, actorProperties) {
    _isolateContext.messages.listen(_handleMessageFromSupervisor);
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
  void _handleActorMailboxMessage(ActorMailboxMessage message) async {
    var type = message.data.runtimeType;

    var handlers = _handlers[type];

    if (handlers != null) {
      var futures = handlers.map((e) => Future(() async {
            await e(message);
          }));

      if (_actorProperties.handlingType == HandlingType.consistently) {
        await Future.wait(futures);

        _isolateContext.supervisorMessagePort
            .send(ActorCompletedTask(_actorProperties.path));
      } else {
        Future(() async {
          await Future.wait(futures);
        }).then((value) {
          _isolateContext.supervisorMessagePort
              .send(ActorCompletedTask(_actorProperties.path));
        }).ignore();
      }
    } else {
      if (message.isHaveSubscription) {
        message.feedbackPort!.send(HandlersNotAssignedResult());
      }
    }

    if (_actorProperties.mailboxType == MailboxType.reliable) {
      _isolateContext.supervisorMessagePort.send(ActorReceivedMessage());
    }
  }

  @override
  void _handleRoutingMessage(RoutingMessage message) {
    if (message.recipientPath == _actorProperties.path) {
      _actorProperties.actorRef.send(ActorMailboxMessage(message.data,
          feedbackPort: message.feedbackPort));
    } else {
      if (message.recipientPath.depthLevel > _actorProperties.path.depthLevel &&
          List.of(message.recipientPath.segments
                  .getRange(0, _actorProperties.path.segments.length))
              .equal(_actorProperties.path.segments)) {
        message.notFound();
      } else {
        _isolateContext.supervisorMessagePort.send(message);
      }
    }
  }
}
