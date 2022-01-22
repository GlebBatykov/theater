part of theater.remote;

abstract class Connector<S extends SecurityConfiguration> {
  final StreamController<ConnectorError> _errorController =
      StreamController.broadcast();

  late final Retryer _retryer;

  final Queue<TransportMessage> _messageQueue = Queue();

  final dynamic address;

  final int port;

  final Duration _timeout;

  final Duration _reconnectTimeout;

  final int _reconnectDelay;

  final S _securityConfiguration;

  bool _isStarted = false;

  bool _isAuthorized = false;

  bool _isDisposed = false;

  bool get isStarted => _isStarted;

  bool get isDisposed => _isDisposed;

  Stream<ConnectorError> get errors => _errorController.stream;

  Connector(this.address, this.port, S securityConfiguration,
      {Duration? timeout, Duration? reconnectTimeout, int? reconnectDelay})
      : _securityConfiguration = securityConfiguration,
        _timeout = timeout ?? const Duration(seconds: 10),
        _reconnectTimeout = reconnectTimeout ?? const Duration(seconds: 10),
        _reconnectDelay = reconnectDelay ?? 100 {
    _retryer = Retryer(duration: _reconnectTimeout);
  }

  Future<void> connect();

  Future<void> close();

  void send(TransportMessage message);

  Future<void> dispose() async {
    await close();
    await _errorController.close();
    _messageQueue.clear();

    _isDisposed = true;
  }
}
