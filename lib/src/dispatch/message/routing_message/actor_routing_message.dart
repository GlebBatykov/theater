part of theater.dispatch;

/// The class is used when routing messages in the actor system.
///
/// It is a message that one actor sends to another without using a link to it.
class ActorRoutingMessage extends RoutingMessage {
  ActorRoutingMessage(data, SendPort feedbackPort, ActorPath recipientPath)
      : super(data, feedbackPort, recipientPath);
}
