part of theater.system_actors;

class ActorSystemServerActor extends SystemActor {
  late final SystemActorContext _context;

  final RemoteTransportConfiguration _remoteConfiguration;

  final List<ConnectorSource> _remoteSources = [];

  final List<String> _serversNames = [];

  final List<String> _connectorsNames = [];

  final IndexStore _tcpServersIndexStore = IndexStore();

  final IndexStore _tcpConnectorsIndexStore = IndexStore();

  ActorSystemServerActor(RemoteTransportConfiguration remoteConfiguration)
      : _remoteConfiguration = remoteConfiguration;

  @override
  Future<void> onStart(SystemActorContext context) async {
    _context = context;

    if (_remoteConfiguration.servers
        .map((e) => e.name)
        .toList()
        .isHaveDuplicate) {
      throw ActorSystemServerInitializeException(
          message: 'multiple servers with the same name.');
    }

    if (_remoteConfiguration.connectors
        .map((e) => e.name)
        .toList()
        .isHaveDuplicate) {
      throw ActorSystemServerInitializeException(
          message: 'multiple connectors with the same name');
    }

    await _initializeServers();

    await _initializeConnectors();
  }

  Future<void> _initializeServers() async {
    await _startTcpServers();
  }

  Future<void> _startTcpServers() async {
    var configurations = _remoteConfiguration.servers
        .whereType<TcpServerConfiguration>()
        .toList();

    for (var configuration in configurations) {
      await _startTcpServer(configuration);
    }
  }

  Future<void> _startTcpServer(TcpServerConfiguration configuration) async {
    if (_serversNames.contains(configuration.name)) {
      throw ActorSystemServerCreateServerException(
          message: 'server named ${configuration.name} already exists.');
    }

    var index = _tcpServersIndexStore.getNext();

    var name = SystemActorNames.tcpServer + '- $index';

    await _context.actorOf(
        name, TcpServerActor(_remoteConfiguration.deserializer, configuration));

    _serversNames.add(configuration.name);
  }

  Future<void> _initializeConnectors() async {
    if (_remoteConfiguration.connectors.isNotEmpty) {
      var receiveRemoteSourcesFuture = _context
          .receiveSeveral<ActorSystemServerAddRemoteSource>(
              _remoteConfiguration.connectors.length, (message) async {
        _remoteSources.add(message.remoteSource);

        return;
      }).then((_) {
        _context.actorProperties.actorSystemSendPort
            .send(ActorSystemSetRemoteSources(_remoteSources));
      });

      await _startTcpConnectors();

      await receiveRemoteSourcesFuture;
    }
  }

  Future<void> _startTcpConnectors() async {
    var configurations = _remoteConfiguration.connectors
        .whereType<TcpConnectorConfiguration>()
        .toList();

    for (var configuration in configurations) {
      await _startTcpConnector(configuration);
    }
  }

  Future<void> _startTcpConnector(
      TcpConnectorConfiguration configuration) async {
    if (_connectorsNames.contains(configuration.name)) {
      throw ActorSystemServerCreateConnectorException(
          message: 'connector named ${configuration.name} already exists.');
    }

    var index = _tcpConnectorsIndexStore.getNext();

    var name = SystemActorNames.tcpConnector + '- $index';

    await _context.actorOf(
        name,
        TcpConnectorActor(
            _context.self, _remoteConfiguration.serializer, configuration));

    _connectorsNames.add(configuration.name);
  }

  @override
  Future<void> handleSystemMessage(
      SystemActorContext context, SystemMessage message) async {
    var data = message.data;

    if (data is ActorSystemServerAction) {
      await _handleActorSystemServerActorAction(message);
    }
  }

  Future<void> _handleActorSystemServerActorAction(
      SystemMessage message) async {
    var action = message.data;

    if (action is ActorSystemServerCreateServer) {
      await _handleActorSystemServerCreateServer(action);
    } else if (action is ActorSystemServerCreateConnector) {
      await _handleActorSystemServerCreateConnector(action);
    }
  }

  Future<void> _handleActorSystemServerCreateServer(
      ActorSystemServerCreateServer action) async {
    var configuration = action.configuration;

    try {
      var isStarted = false;

      if (configuration is TcpServerConfiguration) {
        await _startTcpServer(configuration);

        isStarted = true;
      }

      if (isStarted) {
        action.feedbackPort.send(ActorSystemServerCreateServerSuccess());
      }
    } on ActorSystemServerCreateServerException {
      action.feedbackPort.send(ActorSystemServerCreateServerNameExist());
    }
  }

  Future<void> _handleActorSystemServerCreateConnector(
      ActorSystemServerCreateConnector action) async {
    var configuration = action.configuration;

    try {
      var isStarted = false;

      if (configuration is TcpConnectorConfiguration) {
        await _startTcpConnector(configuration);

        isStarted = true;
      }

      if (isStarted) {
        late HandlerSubscription subscription;

        subscription =
            _context.receive<ActorSystemServerAddRemoteSource>((message) {
          var source = message.remoteSource;

          if (source.connectionName == configuration.name) {
            _remoteSources.add(source);

            action.feedbackPort
                .send(ActorSystemServerCreateConnectorSuccess(source));

            subscription.cancel();
          }

          return;
        });
      }
    } on ActorSystemServerCreateConnectorException {
      action.feedbackPort.send(ActorSystemServerCreateConnectorNameExist());
    }
  }
}
