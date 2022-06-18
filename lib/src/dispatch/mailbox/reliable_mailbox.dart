part of theater.dispatch;

enum HandlingType { asynchronously, consistently }

/// Mailbox which, after sending the message, waits for a delivery confirmation message. Can resend the last message.
class ReliableMailbox extends Mailbox {
  /// Queue of received [MailboxMessage]-s for actor owning this mailbox.
  final Queue<MailboxMessage> _messageQueue = Queue();

  /// Last sended to actor message awaiting successful delivery.
  dynamic _sentMessage;

  /// Indicates whether a message has been sent awaiting successful delivery.
  bool _isMessageSent = false;

  ReliableMailbox(ActorPath path, HandlingType handlingType)
      : super(path, MailboxType.reliable, handlingType) {
    _internalMessageController.stream.listen((message) {
      if (message is MailboxMessage) {
        _handleMailboxMessage(message);
      } else if (message is RoutingMessage) {
        _handleRoutingMessage(message);
      }
    });
  }

  /// Handles all received [MailboxMessage].
  void _handleMailboxMessage(MailboxMessage message) {
    _addMessage(message);

    if (!_isMessageSent) {
      _sendMessage();
    }
  }

  /// Handles all received [RoutingMessage].
  void _handleRoutingMessage(RoutingMessage message) {
    if (message is ActorRoutingMessage) {
      _handleActorRoutingMessage(message);
    } else if (message is SystemRoutingMessage) {
      _handleSystemRoutingMessage(message);
    }
  }

  /// Handles all received [ActorRoutingMessage].
  void _handleActorRoutingMessage(ActorRoutingMessage message) {
    if (message.recipientPath == path) {
      _handleMailboxMessage(ActorMailboxMessage(message.data,
          feedbackPort: message.feedbackPort));
    } else {
      _actorRoutingMessageController.sink.add(message);
    }
  }

  /// Handles all received [SystemRoutingMessage].
  void _handleSystemRoutingMessage(SystemRoutingMessage message) {
    _systemRoutingMessageController.sink.add(message);
  }

  /// Adds message to [_messageQueue].
  void _addMessage(message) => _messageQueue.add(message);

  /// Sends next message to actor from [_messageQueue].
  void next() {
    _isMessageSent = false;

    _sentMessage = null;

    _sendMessage();
  }

  /// Resends last sended message.
  void resend() {
    _mailboxMessageController.sink.add(_sentMessage);
  }

  /// Sends first message from message queue to actor.
  void _sendMessage() {
    if (_messageQueue.isNotEmpty) {
      var message = _messageQueue.removeFirst();

      _mailboxMessageController.sink.add(message);

      _isMessageSent = true;

      _sentMessage = message;
    }
  }
}
