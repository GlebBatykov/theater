part of theater.dispatch;

/// Creates instance of [ReliableMailbox].
class ReliableMailboxFactory extends MailboxFactory<ReliableMailbox> {
  final HandlingType handlingType;

  ReliableMailboxFactory({this.handlingType = HandlingType.asynchronously});

  /// Creates instance of [ReliableMailbox].
  @override
  ReliableMailbox create(MailboxProperties properties) {
    return ReliableMailbox(properties.path, handlingType);
  }
}
