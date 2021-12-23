part of theater.dispatch;

class SystemRoutingMessage extends RoutingMessage {
  SystemRoutingMessage(data, ActorPath recipientPath, {SendPort? feedbackPort})
      : super(data, recipientPath, feedbackPort);
}
