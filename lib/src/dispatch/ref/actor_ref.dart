part of theater.dispatch;

/// Used by sending messages to actor mailbox.
abstract class ActorRef extends Ref {
  /// Sends [message] to actor mailbox.
  void send(dynamic message, {Duration? duration});

  /// Send [message] to actor mailbx and get subscription for this message.
  ///
  /// Use [send] method instead of this methiod if you don't want tracing message status and do not want receive response. Because more message traffic is used to track status and get a response, which degrades throughput.
  MessageSubscription sendAndSubscribe(dynamic message, {Duration? duration});

  /// Sends [message] to actor mailbox. Used by resend someone [ActorMessage] ([MailboxMessage] or [RoutingMessage]) to actor mailbox.
  void sendMessage(ActorMessage message, {Duration? duration});
}
