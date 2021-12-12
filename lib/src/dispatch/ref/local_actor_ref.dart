part of theater.dispatch;

/// Used by sending message to local mailbox actor (located in the same actor system).
class LocalActorRef extends ActorRef {
  /// Path to the actor whose mailbox the ref point to.
  final ActorPath path;

  final SendPort _sendPort;

  LocalActorRef(this.path, SendPort sendPort) : _sendPort = sendPort;

  @override
  void send(dynamic message, {Duration? duration}) {
    if (message is ActorMessage) {
      throw ActorRefException(
          message:
              'message is instance of [ActorMessage], for sending it use [sendMessage] method of [ActorRef].');
    } else {
      if (duration != null) {
        Future.delayed(duration, () {
          _sendPort.send(MailboxMessage(message));
        });
      } else {
        _sendPort.send(MailboxMessage(message));
      }
    }
  }

  @override
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
              MailboxMessage(message, feedbackPort: receivePort.sendPort));
        });
      } else {
        _sendPort
            .send(MailboxMessage(message, feedbackPort: receivePort.sendPort));
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
