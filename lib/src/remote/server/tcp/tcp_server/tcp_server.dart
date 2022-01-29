part of theater.remote;

class TcpServer extends Server<TcpConnection, TcpServerSecurityConfiguration> {
  Stream<Socket>? _serverSocket;

  TcpServer(dynamic address, int port,
      {TcpServerSecurityConfiguration? securityConfiguration})
      : super(address, port,
            securityConfiguration ?? TcpServerSecurityConfiguration());

  TcpServer.fromConfiguration(TcpServerConfiguration configuration)
      : super(
            configuration.address,
            configuration.port,
            configuration.securityConfiguration ??
                TcpServerSecurityConfiguration());

  @override
  Future<void> start() async {
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

        _connections.remove(connection);
      });

      connection.actorMessages.listen((message) {
        _actorMessageController.sink.add(message);
      });

      connection.systemMessages.listen((message) {
        _systemMessageController.sink.add(message);
      });

      connection.initialize();

      _connections.add(connection);
    });

    _isStarted = true;
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

      _isStarted = false;
    }
  }
}
