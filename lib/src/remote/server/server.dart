part of theater.remote;

abstract class Server<C extends Connection, S extends SecurityConfiguration> {
  final StreamController<ActorRemoteMessage> _actorMessageController =
      StreamController.broadcast();

  final StreamController<SystemRemoteMessage> _systemMessageController =
      StreamController.broadcast();

  final dynamic address;

  final List<C> _connections = [];

  final int port;

  final S _securityConfiguration;

  bool _isDisposed = false;

  // ignore: prefer_final_fields
  bool _isStarted = false;

  bool get isStarted => _isStarted;

  bool get isDisposed => _isDisposed;

  Stream<ActorRemoteMessage> get actorMessages =>
      _actorMessageController.stream;

  Stream<SystemRemoteMessage> get systemMessages =>
      _systemMessageController.stream;

  Server(this.address, this.port, S securityConfiguration)
      : _securityConfiguration = securityConfiguration;

  Future<void> start();

  Future<void> close();

  Future<void> dispose() async {
    await _actorMessageController.close();
    await _systemMessageController.close();

    _isDisposed = true;
  }
}
