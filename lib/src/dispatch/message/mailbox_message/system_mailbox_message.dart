part of theater.dispatch;

class SystemMailboxMessage extends SystemMessage with MailboxMessage {
  SystemMailboxMessage(data, SendPort? feedbackPort)
      : super(data, feedbackPort);
}
