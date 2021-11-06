part of theater.dispatch;

class LocalActorRef extends ActorRef {
  final ActorPath path;

  final SendPort _sendPort;

  LocalActorRef(this.path, SendPort sendPort) : _sendPort = sendPort;

  @override
  MessageSubscription send(dynamic message, {Duration? duration}) {
    if (message is ActorMessage) {
      throw ActorRefException(
          message:
              'message is instance of [ActorMessage], for sending it use [sendMessage] method of [ActorRef].');
    } else {
      var receivePort = ReceivePort();

      if (duration != null) {
        Future.delayed(duration, () {
          _sendPort.send(MailboxMessage(message, receivePort.sendPort));
        });
      } else {
        _sendPort.send(MailboxMessage(message, receivePort.sendPort));
      }

      return MessageSubscription(receivePort);
    }
  }

  @override
  void sendMessage(ActorMessage message, {Duration? duration}) {
    if (duration != null) {
      Future.delayed(duration, () {
        _sendPort.send(message);
      });
    } else {
      _sendPort.send(message);
    }
  }
}
