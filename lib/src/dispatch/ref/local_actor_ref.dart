part of theater.dispatch;

/// Used by sending message to local mailbox actor (located in the same actor system).
class LocalActorRef extends ActorRef {
  LocalActorRef(ActorPath path, SendPort sendPort) : super(path, sendPort);

  void send(dynamic message, {Duration? duration}) {
    if (message is ActorMessage) {
      throw ActorRefException(
          message:
              'message is instance of [ActorMessage], for sending it use [sendMessage] method of [ActorRef].');
    } else {
      if (duration != null) {
        Future.delayed(duration, () {
          _sendPort.send(ActorMailboxMessage(message));
        });
      } else {
        _sendPort.send(ActorMailboxMessage(message));
      }
    }
  }

  MessageSubscription sendAndSubscribe(dynamic message, {Duration? duration}) {
    if (message is ActorMessage) {
      throw ActorRefException(
          message:
              'message is instance of [ActorMessage], for sending it use [sendMessage] method of [ActorRef].');
    } else {
      var receivePort = ReceivePort();

      if (duration != null) {
        Future.delayed(duration, () {
          _sendPort.send(
              ActorMailboxMessage(message, feedbackPort: receivePort.sendPort));
        });
      } else {
        _sendPort.send(
            ActorMailboxMessage(message, feedbackPort: receivePort.sendPort));
      }

      return MessageSubscription(receivePort);
    }
  }

  void sendMessage(Message message, {Duration? duration}) {
    if (duration != null) {
      Future.delayed(duration, () {
        _sendPort.send(message);
      });
    } else {
      _sendPort.send(message);
    }
  }
}
