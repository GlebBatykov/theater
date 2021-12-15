part of theater.dispatch;

class RemoteActorRef extends ActorRef {
  @override
  void send(dynamic message, {Duration? duration}) {}

  @override
  MessageSubscription sendAndSubscribe(message, {Duration? duration}) {
    throw UnimplementedError();
  }

  @override
  void sendMessage(ActorMessage message, {Duration? duration}) {
    throw UnimplementedError();
  }
}
