part of theater.actor;

abstract class ActorMessageSender {
  void send(String path, dynamic data, {Duration? delay});

  MessageSubscription sendAndSubscribe(String path, dynamic data,
      {Duration? delay});
}
