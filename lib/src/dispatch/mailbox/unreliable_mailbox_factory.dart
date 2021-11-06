part of theater.dispatch;

/// Creates instance of [UnreliableMailbox].
class UnreliableMailboxFactory extends MailboxFactory<UnreliableMailbox> {
  @override
  UnreliableMailbox create(MailboxProperties properties) {
    return UnreliableMailbox(properties.path);
  }
}
