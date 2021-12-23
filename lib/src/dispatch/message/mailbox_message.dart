part of theater.dispatch;

/// The class is used when routing messages in the actor system.
///
/// It is a message that one actor sends to another using a link to it.
class MailboxMessage extends ActorMessage {
  MailboxMessage(data, {SendPort? feedbackPort}) : super(data, feedbackPort);
}
