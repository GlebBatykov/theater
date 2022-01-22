part of theater.actor;

class TcpConnectorActor extends SystemActor {
  final LocalActorRef _actorServerRef;

  final ActorMessageTransportSerializer _serializer;

  final TcpConnectorConfiguration _configuration;

  late final TcpConnector _connector;

  late final RemoteSourceBridge _sourceBridge;

  TcpConnectorActor(
      LocalActorRef actorServerRef,
      ActorMessageTransportSerializer serializer,
      TcpConnectorConfiguration configuration)
      : _actorServerRef = actorServerRef,
        _serializer = serializer,
        _configuration = configuration;

  @override
  Future<void> onStart(SystemActorContext context) async {
    await initializeConnector();

    await initializeSourceBridge();

    _actorServerRef
        .send(ActorSystemServerActorAddRemoteSource(_sourceBridge.source));
  }

  Future<void> initializeConnector() async {
    _connector = TcpConnector.fromConfiguration(_configuration);

    _connector.errors.listen((error) async {
      await _connector.close();
      await _connector.dispose();

      throw TcpConnectorActorException(
          message: 'connection with name \'' +
              _configuration.name +
              '\' on \'' +
              _configuration.address +
              ':' +
              _configuration.port.toString() +
              ' was interrupted.');
    });

    unawaited(_connector.connect());
  }

  Future<void> initializeSourceBridge() async {
    _sourceBridge = RemoteSourceBridge(_serializer, _configuration.name,
        _configuration.address, _configuration.port);

    _sourceBridge.actorMessages.listen((message) {
      _connector.send(TransportMessage.actorMessage(
          message.path, message.tag, message.data));
    });

    _sourceBridge.systemMessages.listen((message) {
      _connector.send(TransportMessage.systemMessage());
    });
  }

  @override
  Future<void> onKill(SystemActorContext context) async {
    await _connector.close();
    await _connector.dispose();

    await _sourceBridge.dispose();
  }
}
