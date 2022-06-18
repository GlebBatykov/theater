part of theater.dispatch;

/// Mailbox who, after receiving the message, immediately transmits it to his actor.
///
/// Used by default in all actors.
class UnreliableMailbox extends Mailbox {
  UnreliableMailbox(ActorPath path)
      : super(path, MailboxType.unreliable, HandlingType.asynchronously) {
    _internalMessageController.stream.listen((message) {
      if (message is MailboxMessage) {
        _mailboxMessageController.sink.add(message);
      } else if (message is RoutingMessage) {
        _handleRoutingMessage(message);
      }
    });
  }

  void _handleRoutingMessage(RoutingMessage message) {
    if (message is ActorRoutingMessage) {
      _handleActorRoutingMessage(message);
    } else if (message is SystemRoutingMessage) {
      _handleSystemRoutingMessage(message);
    }
  }

  void _handleActorRoutingMessage(ActorRoutingMessage message) {
    if (message.recipientPath == path) {
      _mailboxMessageController.sink.add(ActorMailboxMessage(message.data,
          feedbackPort: message.feedbackPort));
    } else {
      _actorRoutingMessageController.sink.add(message);
    }
  }

  void _handleSystemRoutingMessage(SystemRoutingMessage message) {
    _systemRoutingMessageController.sink.add(message);
  }
}
