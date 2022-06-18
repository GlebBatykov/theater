part of theater.remote;

class TcpConnector extends Connector<TcpConnectorSecurityConfiguration> {
  Socket? _socket;

  TcpConnector(
    String name,
    dynamic address,
    int port, {
    TcpConnectorSecurityConfiguration? securityConfiguration,
    Duration? timeout,
    Duration? reconnectTimeout,
    double? reconnectDelay,
  }) : super(name, address, port,
            securityConfiguration ?? TcpConnectorSecurityConfiguration(),
            timeout: timeout,
            reconnectTimeout: reconnectTimeout,
            reconnectDelay: reconnectDelay);

  TcpConnector.fromConfiguration(TcpConnectorConfiguration configuration)
      : super(
            configuration.name,
            configuration.address,
            configuration.port,
            configuration.securityConfiguration ??
                TcpConnectorSecurityConfiguration(),
            timeout: configuration.timeout,
            reconnectTimeout: configuration.reconnectTimeout,
            reconnectDelay: configuration.reconnectDelay);

  @override
  Future<void> connect() async {
    await _retryer.execute(_connect);

    if (!_isStarted) {
      _errorController.sink.add(ConnectorConnectionError());
    }
  }

  Future<void> _connect() async {
    if (_securityConfiguration.haveContext) {
      _socket = await SecureSocket.connect(address, port,
          context: _securityConfiguration.securityContext,
          onBadCertificate: _securityConfiguration.onBadCertificate,
          timeout: _timeout);
    } else {
      _socket = await Socket.connect(address, port, timeout: _timeout);
    }

    _socket!.listen(_handleMessage, onError: (error) {
      _errorController.sink.add(ConnectorConnectionInterruptedError());
    }, onDone: () {
      _errorController.sink.add(ConnectorConnectionInterruptedError());
    });

    _isStarted = true;

    if (!_securityConfiguration.haveKey) {
      _sendMessageQueue();
    }

    _authorization();
  }

  void _handleMessage(Uint8List bytes) {
    var message = RemoteTransportMessageDeserializer.deserialize(bytes);

    var event = RemoteTransportEventDeserializer.deserialize(
        message.type, message.data);

    _handleEvent(event);
  }

  void _handleEvent(RemoteTransportEvent event) {
    if (event is AuthorizationEvent) {
      _handleAuthorizationEvent(event);
    } else if (event is SystemMessageEvent) {
      _handleSystemMessageEvent(event);
    }
  }

  void _handleAuthorizationEvent(AuthorizationEvent event) {
    if (event is SuccessAuthorizationEvent) {
      _isAuthorized = true;

      _sendMessageQueue();
    } else if (event is InvalidAuthorizationEvent) {
      _errorController.sink.add(ConnectorInvalidAuthorizationError());
    }
  }

  void _handleSystemMessageEvent(SystemMessageEvent event) {
    if (event is GetActorsPathsResult) {
      _systemMessageController.sink
          .add(GetActorsPathsResultTransportMessage(event.id, event.paths));
    }
  }

  void _authorization() {
    if (_securityConfiguration.haveKey) {
      var message = TransportMessage.login(_securityConfiguration.key!);

      _socket!.write(RemoteTransportMessageSerializer.serialize(message));

      Future.delayed(_securityConfiguration.timeout, () {
        if (!_isAuthorized) {
          _errorController.sink.add(ConnectorAuthorizationTimeoutError());
        }
      });
    }
  }

  @override
  Future<void> close() async {
    if (_isStarted) {
      await _socket!.close();

      _socket = null;

      await super.close();
    }
  }

  @override
  void send(TransportMessage message) {
    if ((!_securityConfiguration.haveKey && _isStarted) ||
        (_isStarted && _securityConfiguration.haveKey && _isAuthorized)) {
      var data = RemoteTransportMessageSerializer.serialize(message);

      _socket!.write(data);
    } else {
      _messageQueue.add(message);
    }
  }

  void _sendMessageQueue() {
    while (_messageQueue.isNotEmpty) {
      var message = _messageQueue.removeFirst();

      send(message);
    }
  }
}
