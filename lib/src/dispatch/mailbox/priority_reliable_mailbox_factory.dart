part of theater.dispatch;

/// Factory class creating instance of [PriorityReliableMailbox] with [priorityGenerator].
class PriorityReliableMailboxFactory extends ReliableMailboxFactory {
  final PriorityGenerator priorityGenerator;

  PriorityReliableMailboxFactory(
      {required this.priorityGenerator, super.handlingType});

  /// Creates instance of [PriorityReliableMailbox].
  @override
  PriorityReliableMailbox create(MailboxProperties properties) {
    return PriorityReliableMailbox(properties.path, handlingType,
        priorityGenerator: priorityGenerator);
  }
}
