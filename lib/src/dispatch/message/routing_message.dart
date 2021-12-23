part of theater.dispatch;

abstract class RoutingMessage extends ActorMessage {
  final ActorPath recipientPath;

  RoutingMessage(data, this.recipientPath, SendPort? feedbackPort)
      : super(data, feedbackPort);
}
