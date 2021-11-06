part of theater.dispatch;

/// This class is a base class for all mailbox factory classes.
abstract class MailboxFactory<T extends Mailbox> {
  /// Creates instance of [T].
  T create(MailboxProperties properties);
}
