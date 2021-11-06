part of theater.dispatch;

class SystemRoutingMessage extends RoutingMessage {
  SystemRoutingMessage(data, SendPort feedbackPort, ActorPath recipientPath)
      : super(data, feedbackPort, recipientPath);
}
