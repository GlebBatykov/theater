part of theater.dispatch;

class SystemRoutingMessage extends SystemMessage with RoutingMessage {
  @override
  final ActorPath recipientPath;

  SystemRoutingMessage(dynamic data, this.recipientPath,
      {SendPort? feedbackPort})
      : super(data, feedbackPort: feedbackPort);
}
