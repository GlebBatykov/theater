part of theater.system_actors;

class ActorSystemServerActor extends SystemActor {
  final RemoteTransportConfiguration _remoteConfiguration;

  final List<RemoteSource> _remoteSources = [];

  ActorSystemServerActor(RemoteTransportConfiguration remoteConfiguration)
      : _remoteConfiguration = remoteConfiguration;

  @override
  Future<void> onStart(SystemActorContext context) async {
    await initializeServers(context);

    await initializeConnectors(context);
  }

  Future<void> initializeServers(SystemActorContext context) async {
    await startTcpServers(context);
  }

  Future<void> startTcpServers(SystemActorContext context) async {
    var configurations = _remoteConfiguration.servers
        .whereType<TcpServerConfiguration>()
        .toList();

    for (var i = 0; i < configurations.length; i++) {
      var name = 'tcp-server-' + (i + 1).toString();

      await context.actorOf(name,
          TcpServerActor(_remoteConfiguration.deserializer, configurations[i]));
    }
  }

  Future<void> initializeConnectors(SystemActorContext context) async {
    if (_remoteConfiguration.connectors.isNotEmpty) {
      var receiveRemoteSourcesFuture = context
          .receiveSeveral<ActorSystemServerActorAddRemoteSource>(
              _remoteConfiguration.connectors.length, (message) async {
        _remoteSources.add(message.remoteSource);
      }).then((_) {
        context.actorProperties.actorSystemMessagePort
            .send(ActorSystemSetRemoteSources(_remoteSources));
      });

      await startTcpConnectors(context);

      await receiveRemoteSourcesFuture;
    }
  }

  Future<void> startTcpConnectors(SystemActorContext context) async {
    var configurations = _remoteConfiguration.connectors
        .whereType<TcpConnectorConfiguration>()
        .toList();

    for (var i = 0; i < configurations.length; i++) {
      var name = 'tcp-connector-' + (i + 1).toString();

      await context.actorOf(
          name,
          TcpConnectorActor(context.itself, _remoteConfiguration.serializer,
              configurations[i]));
    }
  }
}
