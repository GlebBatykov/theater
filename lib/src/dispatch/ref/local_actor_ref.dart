part of theater.dispatch;

/// Used by sending message to local mailbox actor (located in the same actor system).
class LocalActorRef extends ActorRef {
  LocalActorRef(ActorPath path, SendPort sendPort) : super(path, sendPort);

  /// Sends message to actor which in located on [path].
  ///
  /// If [delay] is not null, message sends after delay equals [delay].
  ///
  /// You have two way how point out path to actor:
  ///
  /// - relative;
  /// - absolute.
  ///
  /// The relative path is set from current actor.
  ///
  /// For example, current actor is "first_actor" - you can point out this path "system/root/user/first_actor/second_actor" like "../second_actor".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
  void send(dynamic message, {Duration? duration}) {
    if (![
      ActorMailboxMessage,
      SystemMailboxMessage,
      ActorRoutingMessage,
      SystemRoutingMessage
    ].contains(message.runtimeType)) {
      message = ActorMailboxMessage(message);
    }

    if (duration != null) {
      Future.delayed(duration, () {
        _sendPort.send(message);
      });
    } else {
      _sendPort.send(message);
    }
  }

  /// Sends message to actor which in located on [path] and return subscribe to message.
  ///
  /// If [delay] is not null, message sends after delay equals [delay].
  ///
  /// You have two way how point out path to actor:
  ///
  /// - relative;
  /// - absolute.
  ///
  /// The relative path is set from current actor.
  ///
  /// For example, current actor is "first_actor" - you can point out this path "system/root/user/first_actor/second_actor" like "../second_actor".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
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
}
