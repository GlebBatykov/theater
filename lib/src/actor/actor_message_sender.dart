part of theater.actor;

abstract class ActorMessageSender {
  MessageSubscription send(String path, dynamic data, {Duration? duration});
}
