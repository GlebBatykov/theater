part of theater.dispatch;

mixin RoutingMessage on Message {
  ActorPath get recipientPath;
}
