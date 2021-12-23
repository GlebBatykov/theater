part of theater.dispatch;

/// Creates instance of [ReliableMailbox].
class ReliableMailboxFactory extends MailboxFactory<ReliableMailbox> {
  /// Creates instance of [ReliableMailbox].
  @override
  ReliableMailbox create(MailboxProperties properties) {
    return ReliableMailbox(properties.path);
  }
}
