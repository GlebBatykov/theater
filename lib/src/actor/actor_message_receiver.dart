part of theater.actor;

mixin ActorMessageReceiver<P extends ActorProperties> on ActorContext<P> {
  StreamSubscription<MailboxMessage> receive<T>(
      Future<MessageResult?> Function(T) handler) {
    var subscription = _messageController.stream.listen((message) async {
      if (message.data is T) {
        var result = await handler(message.data);

        result != null ? message.sendResult(result.data) : message.successful();
      }
    });

    return subscription;
  }
}
