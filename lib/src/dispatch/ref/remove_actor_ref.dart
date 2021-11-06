part of theater.dispatch;

class RemoveActorRef extends ActorRef {
  @override
  MessageSubscription send(message, {Duration? duration}) {
    throw UnimplementedError();
  }

  @override
  void sendMessage(ActorMessage message, {Duration? duration}) {
    throw UnimplementedError();
  }
}
