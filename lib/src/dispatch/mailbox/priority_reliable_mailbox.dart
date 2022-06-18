part of theater.dispatch;

/// Mailbox which, after sending the message, waits for a delivery confirmation message. Can resend the last message.
///
/// Used [PriorityGenerator] for generate priority to all received messages and rebuild message queue.
class PriorityReliableMailbox extends ReliableMailbox {
  final PriorityGenerator _priorityGenerator;

  PriorityReliableMailbox(ActorPath path, HandlingType handlingType,
      {required PriorityGenerator priorityGenerator})
      : _priorityGenerator = priorityGenerator,
        super(path, handlingType);

  /// Adds message to [_messageQueue] and rebuild [_messageQueue] according to the priority of the message.
  @override
  void _addMessage(message) {
    _messageQueue.add(message);

    var list = _messageQueue.toList();

    for (var i = 0; i < list.length - 1; i++) {
      if (_priorityGenerator.generatePriority(list[i].data) <
          _priorityGenerator.generatePriority(list[i + 1].data)) {
        var temp = list[i];
        list[i] = list[i + 1];
        list[i + 1] = temp;

        i = -1;
      }
    }

    _messageQueue.clear();
    _messageQueue.addAll(list);
  }
}
