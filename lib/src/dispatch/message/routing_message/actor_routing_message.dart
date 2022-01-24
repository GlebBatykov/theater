part of theater.dispatch;

/// The class is used when routing messages in the actor system.
///
/// It is a message that one actor sends to another without using a link to it.
class ActorRoutingMessage extends ActorMessage with RoutingMessage {
  @override
  final ActorPath recipientPath;

  ActorRoutingMessage(dynamic data, this.recipientPath,
      {SendPort? feedbackPort})
      : super(data, feedbackPort);
}
