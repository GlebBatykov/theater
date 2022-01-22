part of theater.actor;

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
      context.actorProperties.actorSystemMessagePort.send(
          ActorSystemRouteActorRemoteMessage(ActorRemoteMessage(
              message.path,
              message.tag,
              _deserializer.deserialize(message.tag, message.data))));
    });

    _server.systemMessages.listen((message) {});

    await _server.start();
  }

  @override
  Future<void> onKill(SystemActorContext context) async {
    await _server.close();
    await _server.dispose();
  }
}
