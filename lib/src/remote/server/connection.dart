part of theater.remote;

abstract class Connection<S extends SecurityConfiguration> {
  final StreamController<ConnectionError> _errorController =
      StreamController.broadcast();

  final StreamController<ActorRemoteMessage> _actorMessageController =
      StreamController.broadcast();

  final StreamController<SystemRemoteMessage> _systemMessageController =
      StreamController.broadcast();

  final S _securityConfiguration;

  bool _isClose = false;

  bool _isAuthorized = false;

  bool _isDispose = false;

  bool get isDispose => _isDispose;

  Stream<ConnectionError> get errors => _errorController.stream;

  Stream<ActorRemoteMessage> get actorMessages =>
      _actorMessageController.stream;

  Stream<SystemRemoteMessage> get systemMessages =>
      _systemMessageController.stream;

  Connection(S securityConfiguration)
      : _securityConfiguration = securityConfiguration;

  void initialize();

  Future<void> close();

  Future<void> dispose() async {
    await close();

    await _actorMessageController.close();
    await _systemMessageController.close();

    _isDispose = true;
  }
}
