part of theater.system_actors;

class TcpServerActor extends SystemActor {
  final ActorMessageTransportDeserializer _deserializer;

  final TcpServerConfiguration _configuration;

  late final TcpServer _server;

  TcpServerActor(ActorMessageTransportDeserializer deserializer,
      TcpServerConfiguration configuration)
      : _deserializer = deserializer,
        _configuration = configuration;

  @override
  Future<void> onStart(SystemActorContext context) async {
    _server = TcpServer.fromConfiguration(_configuration);

    _server.actorMessages.listen((message) {
      _handleActorRemoteMessage(context, message);
    });

    _server.systemMessages.listen((message) {
      _handleSystemRemoteMessage(context, message);
    });

    _server.addConnection.listen((connection) {
      context.actorProperties.actorSystemSendPort.send(ActorSystemNotify(
          ActorSystemNotificationType.addIncomingConnection, connection));
    });

    _server.removeConnection.listen((connection) {
      context.actorProperties.actorSystemSendPort.send(ActorSystemNotify(
          ActorSystemNotificationType.removeIncomingConnection, connection));
    });

    await _server.start();
  }

  void _handleActorRemoteMessage(
      SystemActorContext context, ActorRemoteMessage message) {
    context.actorProperties.actorSystemSendPort.send(
        ActorSystemRouteActorRemoteMessage(ActorRemoteMessage(
            message.path,
            message.tag,
            _deserializer.deserialize(message.tag, message.data))));
  }

  void _handleSystemRemoteMessage(
      SystemActorContext context, SystemMessageDetails details) async {
    var message = details.remoteMessage;

    if (message is GetActorsPathsTransportMessage) {
      var paths = await context.getActorsPaths();

      await details.sender
          .send(TransportMessage.getActorsPathsResult(message.id, paths));
    }
  }

  @override
  Future<void> onKill(SystemActorContext context) async {
    await _server.close();

    await _server.dispose();
  }
}
