part of theater.remote;

class TcpConnection<S extends TcpSecurityConfiguration> extends Connection<S> {
  final Socket _socket;

  @override
  dynamic get address => _socket.address.address;

  @override
  int get port => _socket.port;

  TcpConnection(Socket socket, S securityConfiguration)
      : _socket = socket,
        super(securityConfiguration);

  @override
  void initialize() {
    _socket.listen(_handleMessage, onDone: () {
      _isClose = true;
      _errorController.sink.add(ConnectionInterruptedError());
    }, onError: (error) {
      _isClose = true;
      _errorController.sink.add(ConnectionInterruptedError());
    });

    if (_securityConfiguration.haveKey) {
      Future.delayed(_securityConfiguration.timeout, () {
        if (!_isAuthorized) {
          _errorController.sink.add(ConnectionAuthorizationTimeoutError());
        }
      });
    }
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
    } else if (event is MessageEvent) {
      _handleMessageEvent(event);
    }
  }

  void _handleAuthorizationEvent(AuthorizationEvent event) {
    if (event is LoginEvent) {
      if (event.key == _securityConfiguration.key) {
        _sendMessage(TransportMessage.successAuthorization());

        _isAuthorized = true;
      } else {
        _sendMessage(TransportMessage.invalidAuthorization());

        _errorController.sink.add(ConnectionInvalidAuthorizationError());
      }
    }
  }

  void _handleMessageEvent(MessageEvent event) {
    if (event is ActorMessageEvent) {
      _actorMessageController.sink
          .add(ActorRemoteMessage(event.path, event.tag, event.data));
    } else if (event is GetActorsPaths) {
      _systemMessageController.sink
          .add(GetActorsPathsTransportMessage(event.id));
    }
  }

  void _sendMessage(TransportMessage message) {
    if (!_isClose) {
      var data = RemoteTransportMessageSerializer.serialize(message);

      _socket.write(data);
    }
  }

  @override
  Future<void> send(TransportMessage message) async {
    if ((!_securityConfiguration.haveKey && !_isClose) ||
        (!_isClose && _securityConfiguration.haveKey && _isAuthorized)) {
      var data = RemoteTransportMessageSerializer.serialize(message);

      _socket.write(data);
    }
  }

  @override
  Future<void> close() async {
    await _socket.close();

    await super.close();
  }
}
