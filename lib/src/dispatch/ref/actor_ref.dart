part of theater.dispatch;

abstract class ActorRef {
  MessageSubscription send(dynamic message, {Duration? duration});

  void sendMessage(ActorMessage message, {Duration? duration});
}
