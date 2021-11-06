part of theater.dispatch;

/// Creates instance of [ReliabilityMailbox].
class ReliableMailboxFactory extends MailboxFactory<ReliableMailbox> {
  /// Creates instance of [ReliabilityMailbox].
  @override
  ReliableMailbox create(MailboxProperties properties) {
    return ReliableMailbox(properties.path);
  }
}
