part of theater.dispatch;

class ActorMailboxMessage extends ActorMessage with MailboxMessage {
  ActorMailboxMessage(data, {SendPort? feedbackPort})
      : super(data, feedbackPort);
}
