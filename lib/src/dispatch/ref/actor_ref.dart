part of theater.dispatch;

/// Used by sending messages to actor mailbox.
abstract class ActorRef {
  /// Sends [message] to actor mailbox.
  MessageSubscription send(dynamic message, {Duration? duration});

  /// Sends [message] to actor mailbox. Used by resend someone [ActorMessage] ([MailboxMessage] or [RoutingMessage]) to actor mailbox.
  void sendMessage(ActorMessage message, {Duration? duration});
}
