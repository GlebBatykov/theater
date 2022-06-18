part of theater.remote;

class TcpServer extends Server<TcpConnection, TcpServerSecurityConfiguration> {
  Stream<Socket>? _serverSocket;

  TcpServer(String name, int port,
      {TcpServerSecurityConfiguration? securityConfiguration})
      : super(name, port,
            securityConfiguration ?? TcpServerSecurityConfiguration());

  TcpServer.fromConfiguration(TcpServerConfiguration configuration)
      : super(
            configuration.name,
            configuration.port,
            configuration.securityConfiguration ??
                TcpServerSecurityConfiguration());

  @override
  Future<void> start() async {
    var address = InternetAddress.anyIPv4;

    if (_securityConfiguration.haveContext) {
      _serverSocket = await SecureServerSocket.bind(
          address, port, _securityConfiguration.securityContext);
    } else {
      _serverSocket = await ServerSocket.bind(address, port);
    }

    _serverSocket!.listen((socket) {
      var connection = TcpConnection(socket, _securityConfiguration);

      connection.errors.listen((error) async {
        await connection.close();
        await connection.dispose();

        _removeConnection(connection);
      });

      connection.actorMessages.listen((message) {
        _actorMessageController.sink.add(message);
      });

      connection.systemMessages.listen((message) {
        _systemMessageController.sink
            .add(SystemMessageDetails(message, connection));
      });

      connection.initialize();

      _addConnecton(connection);
    });

    _isStarted = true;
  }

  void _removeConnection(TcpConnection connection) {
    _connections.remove(connection);

    _removeConnectionController.sink.add(IncomingConnection(
        connection.address, connection.port, InternetProtocol.tcp, name));
  }

  void _addConnecton(TcpConnection connection) {
    _connections.add(connection);

    _addConnectionController.sink.add(IncomingConnection(
        connection.address, connection.port, InternetProtocol.tcp, name));
  }

  @override
  Future<void> close() async {
    if (_isStarted) {
      for (var connection in _connections) {
        await connection.close();

        await connection.dispose();
      }

      if (_securityConfiguration.haveContext) {
        await (_serverSocket as SecureServerSocket).close();
      } else {
        await (_serverSocket as ServerSocket).close();
      }

      await super.close();
    }
  }
}
