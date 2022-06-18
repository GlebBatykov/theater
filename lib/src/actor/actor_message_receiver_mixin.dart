part of theater.actor;

enum HandlePriority { event, microtask }

mixin ActorMessageReceiverMixin<P extends ActorProperties> on ActorContext<P> {
  /// Sets [handler] to handle all messages of type [T] that received actor.
  HandlerSubscription receive<T>(MessageHandler<T> handler,
      {HandlePriority priority = HandlePriority.event}) {
    var handlers = _getHandlers(T);

    var messageHandler = _getMessageHandler(handler, priority);

    handlers.add(messageHandler);

    var subscription = HandlerSubscription(() {
      _removeMessageHandler(T, messageHandler);
    });

    return subscription;
  }

  /// Sets [handler] to only for [count] following messages of type [T].
  ///
  /// After handled [count] of messages cancels handling messages and completes [Future].
  Future<void> receiveSeveral<T>(int count, MessageHandler<T> handler,
      {HandlePriority priority = HandlePriority.event}) async {
    var handlers = _getHandlers(T);

    var counter = 0;

    var controller = StreamController();

    late Future<void> Function(ActorMailboxMessage) messageHandler;

    messageHandler = (ActorMailboxMessage message) async {
      await _getMessageHandler(handler, priority).call(message);

      controller.sink.add(null);
    };

    handlers.add(messageHandler);

    await for (var _ in controller.stream) {
      if (++counter == count) {
        _removeMessageHandler(T, messageHandler);

        break;
      }
    }

    await controller.close();
  }

  Future<void> Function(ActorMailboxMessage message) _getMessageHandler<T>(
      MessageHandler<T> handler, HandlePriority priority) {
    return (ActorMailboxMessage message) async {
      MessageResult? result;

      if (priority == HandlePriority.event) {
        result = await handler(message.data);
      } else {
        result = await Future.microtask(() => handler(message.data));
      }

      if (message.isHaveSubscription) {
        result != null ? message.sendResult(result.data) : message.successful();
      }
    };
  }

  List<ActorMailboxMessageHandler> _getHandlers(Type type) {
    if (!_handlers.containsKey(type)) {
      _handlers[type] = [];
    }

    return _handlers[type]!;
  }

  void _removeMessageHandler(Type type, ActorMailboxMessageHandler handler) {
    var handlers = _handlers[type]!;

    handlers.remove(handler);

    if (handlers.isEmpty) {
      _handlers.remove(type);
    }
  }
}
