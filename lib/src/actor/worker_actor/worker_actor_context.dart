part of theater.actor;

/// The class used by [WorkerActor] to communicate with other actors in the actor system, receive messages from other actors.
class WorkerActorContext<P extends WorkerActorProperties>
    extends SheetActorContext<P> with UserActorContextMixin<P> {
  final Map<Type, List<Function>> _receiveHandlers = {};

  WorkerActorContext(IsolateContext isolateContext, P actorProperties)
      : super(isolateContext, actorProperties) {
    _isolateContext.messages.listen(_handleMessageFromSupervisor);

    _messageController.stream.listen((message) async {
      var type = message.data.runtimeType;

      if (_receiveHandlers.keys.contains(type)) {
        await Future.wait(
            _receiveHandlers[type]!.map((element) => Future(() async {
                  var result = await element(message.data);

                  if (message.isHaveSubscription) {
                    result != null
                        ? message.sendResult(result.data)
                        : message.successful();
                  }
                })));

        _isolateContext.supervisorMessagePort
            .send(ActorCompletedTask(_actorProperties.path));
      }
    });
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
      _messageController.sink.add(message);

      if (_actorProperties.mailboxType == MailboxType.reliable) {
        _isolateContext.supervisorMessagePort.send(ActorReceivedMessage());
      }
    }
  }

  @override
  void _handleRoutingMessage(RoutingMessage message) {
    if (message.recipientPath == _actorProperties.path) {
      _actorProperties.actorRef.sendMessage(ActorMailboxMessage(message.data,
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

  void receive<T>(Future<MessageResult?> Function(T) handler) {
    if (_receiveHandlers.keys.contains(T)) {
      _receiveHandlers[T]!.add(handler);
    } else {
      _receiveHandlers[T] = [handler];
    }
  }
}
