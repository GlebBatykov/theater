part of theater.dispatch;

/// Factory class creating instance of [PriorityReliableMailbox] with [priorityGenerator].
class PriorityReliableMailboxFactory extends MailboxFactory<ReliableMailbox> {
  final PriorityGenerator priorityGenerator;

  PriorityReliableMailboxFactory({required this.priorityGenerator});

  /// Creates instance of [PriorityReliableMailbox].
  @override
  PriorityReliableMailbox create(MailboxProperties properties) {
    return PriorityReliableMailbox(properties.path,
        priorityGenerator: priorityGenerator);
  }
}
