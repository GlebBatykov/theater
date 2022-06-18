part of theater.remote;

abstract class Server<C extends Connection, S extends SecurityConfiguration> {
  final StreamController<ActorRemoteMessage> _actorMessageController =
      StreamController.broadcast();

  final StreamController<SystemMessageDetails> _systemMessageController =
      StreamController.broadcast();

  final StreamController<IncomingConnection> _addConnectionController =
      StreamController.broadcast();

  final StreamController<IncomingConnection> _removeConnectionController =
      StreamController.broadcast();

  final String name;

  final List<C> _connections = [];

  final int port;

  final S _securityConfiguration;

  bool _isDisposed = false;

  bool _isStarted = false;

  bool get isStarted => _isStarted;

  bool get isDisposed => _isDisposed;

  Stream<ActorRemoteMessage> get actorMessages =>
      _actorMessageController.stream;

  Stream<SystemMessageDetails> get systemMessages =>
      _systemMessageController.stream;

  Stream<IncomingConnection> get addConnection =>
      _addConnectionController.stream;

  Stream<IncomingConnection> get removeConnection =>
      _removeConnectionController.stream;

  Server(this.name, this.port, S securityConfiguration)
      : _securityConfiguration = securityConfiguration;

  Future<void> start();

  Future<void> close() async {
    _isStarted = false;
  }

  Future<void> dispose() async {
    await _actorMessageController.close();
    await _systemMessageController.close();

    await _addConnectionController.close();
    await _removeConnectionController.close();

    _isDisposed = true;
  }
}
