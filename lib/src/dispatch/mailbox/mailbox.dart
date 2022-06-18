part of theater.dispatch;

/// Mailbox is a base class for all mailbox classes.
abstract class Mailbox {
  /// Instance of [StreamController] for [ActorMailboxMessage]-s received from this mailbox.
  final StreamController<MailboxMessage> _mailboxMessageController =
      StreamController.broadcast();

  /// Instance of [StreamController] for [ActorRoutingMessage]-s received from this mailbox.
  final StreamController<ActorRoutingMessage> _actorRoutingMessageController =
      StreamController.broadcast();

  /// Instance of [StreamController] for [SystemRoutingMessage]-s received from this mailbox.
  final StreamController<SystemRoutingMessage> _systemRoutingMessageController =
      StreamController.broadcast();

  /// Instance of [StreamController] for all [ActorMessage] which received from [_receivePort].
  ///
  /// Used for initial receipt [ActorMessage] from [_receivePort] and their subsequent division.
  final StreamController<Message> _internalMessageController =
      StreamController.broadcast();

  /// Instance of [ReceivePort] used by receive messages to current mailbox.
  final ReceivePort _receivePort = ReceivePort();

  /// Broadcast stream derived from [_receivePort].
  late final Stream _receiveStream;

  /// Type of current mailbox.
  final MailboxType type;

  ///
  final HandlingType handlingType;

  /// Path to actor owning this mailbox.
  final ActorPath path;

  /// Displays whether the mailbox has been disposed.
  bool _isDisposed = false;

  /// Send port used for sends messages for mailbox.
  SendPort get sendPort => _receivePort.sendPort;

  /// Displays whether the mailbox has been disposed.
  bool get isDisposed => _isDisposed;

  /// Stream of [ActorMailboxMessage] from mailbox.
  Stream<MailboxMessage> get mailboxMessages =>
      _mailboxMessageController.stream;

  /// Stream of [ActorRoutingMessage] from mailbox.
  Stream<ActorRoutingMessage> get actorRoutingMessages =>
      _actorRoutingMessageController.stream;

  /// Stream of [SystemRoutingMessage] from mailbox.
  Stream<SystemRoutingMessage> get systemRoutingMessages =>
      _systemRoutingMessageController.stream;

  Mailbox(this.path, this.type, this.handlingType) {
    _receiveStream = _receivePort.asBroadcastStream();

    _receiveStream.listen(_receiveMessage);
  }

  /// Receives messages from [_receivePort].
  void _receiveMessage(message) {
    if (message is Message) {
      _internalMessageController.sink.add(message);
    }
  }

  /// Disposes mailbox. Closes receive port, all stream controllers.
  ///
  /// After dispose mailbox cannot function.
  Future<void> dispose() async {
    await _mailboxMessageController.close();
    await _actorRoutingMessageController.close();
    await _systemRoutingMessageController.close();
    await _internalMessageController.close();
    _receivePort.close();
    _isDisposed = true;
  }
}
