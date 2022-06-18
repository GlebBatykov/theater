part of theater.system_actors;

class TcpConnectorActor extends SystemActor {
  final LocalActorRef _actorServerRef;

  final ActorMessageTransportSerializer _serializer;

  final TcpConnectorConfiguration _configuration;

  final List<ProcessedRequest> _processedRequests = [];

  late final TcpConnector _connector;

  late final ConnectorBridge _bridge;

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

    _actorServerRef.send(ActorSystemServerAddRemoteSource(_bridge.source));
  }

  Future<void> initializeConnector() async {
    _connector = TcpConnector.fromConfiguration(_configuration);

    _connector.systemMessages.listen(_handleSystemRemoteMessage);

    _connector.errors.listen((error) async {
      await _connector.close();

      await _connector.dispose();

      throw TcpConnectorActorException(
          message:
              'connection with name \'${_configuration.name}\' on \' ${_configuration.address}\':${_configuration.port} + was interrupted.');
    });

    _connector.connect().ignore();
  }

  void _handleSystemRemoteMessage(SystemRemoteTransportMessage message) {
    if (message is GetActorsPathsResultTransportMessage) {
      var request = _processedRequests.firstWhere((element) =>
          element.id == message.id &&
          element.type == ProcessedRequestType.getActorsPaths);

      request.feedbackPort.send(GetActorsPathsResultMessage(message.paths));

      _processedRequests.remove(request);
    }
  }

  Future<void> initializeSourceBridge() async {
    _bridge = ConnectorBridge(_serializer, _configuration.name,
        _configuration.address, _configuration.port, InternetProtocol.tcp);

    _bridge.actorMessages.listen((message) {
      _connector.send(TransportMessage.actorMessage(
          message.path, message.tag, message.data));
    });

    _bridge.systemMessages.listen(_handleSystemRemoteTransportMessage);
  }

  void _handleSystemRemoteTransportMessage(SystemRemoteMessage message) {
    if (message is GetActorsPathsMessage) {
      _handleGetActorsPathsMessage(message);
    }
  }

  void _handleGetActorsPathsMessage(GetActorsPathsMessage message) {
    late int id;

    var random = Random();

    do {
      id = random.nextInt(maxInt);
    } while (_requestExist(id));

    _processedRequests.add(ProcessedRequest(
        id, ProcessedRequestType.getActorsPaths, message.feedbackPort));

    _connector.send(TransportMessage.getActorsPaths(id));
  }

  bool _requestExist(int id) {
    var isExist = false;

    for (var request in _processedRequests) {
      if (request.id == id) {
        isExist = true;
        break;
      }
    }

    return isExist;
  }

  @override
  Future<void> onKill(SystemActorContext context) async {
    await _connector.close();

    await _connector.dispose();

    await _bridge.dispose();
  }
}
