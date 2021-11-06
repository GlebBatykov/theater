part of theater.dispatch;

abstract class RoutingMessage extends ActorMessage {
  final ActorPath recipientPath;

  RoutingMessage(data, SendPort feedbackPort, this.recipientPath)
      : super(data, feedbackPort);
}
