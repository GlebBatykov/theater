part of theater.actor;

mixin ActorMessageReceiverMixin<P extends ActorProperties> on ActorContext<P> {
  /// Sets [handler] to handle all messages of type [T] that received actor.
  StreamSubscription<MailboxMessage> receive<T>(
      Future<MessageResult?> Function(T) handler) {
    var subscription = _messageController.stream.listen((message) async {
      if (message.data is T) {
        var result = await handler(message.data);

        if (message.isHaveSubscription) {
          result != null
              ? message.sendResult(result.data)
              : message.successful();
        }
      }
    });

    return subscription;
  }

  /// Sets [handler] to only for [count] following messages of type [T].
  ///
  /// After handled [count] of messages cancels handling messages and completes [Future].
  Future<void> receiveSeveral<T>(
      int count, Future<MessageResult?> Function(T) handler) async {
    var counter = 0;

    var controller = StreamController<MailboxMessage>();

    controller.stream.listen((message) async {
      var result = await handler(message.data);

      if (message.isHaveSubscription) {
        result != null ? message.sendResult(result.data) : message.successful();
      }
    });

    await for (var message in _messageController.stream) {
      if (message.data is T) {
        controller.sink.add(message);

        if (++counter == count) {
          break;
        }
      }
    }

    await controller.close();
  }
}
