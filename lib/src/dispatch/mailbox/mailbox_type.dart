part of theater.dispatch;

/// Mailboxes are divided into two types:
/// - unreliable. Mailbox without confirmation of delivery.
/// - reliable. Mailbox with confirmation of delivery.
enum MailboxType { reliable, unreliable }
