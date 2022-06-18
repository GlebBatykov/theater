part of theater.system_actors;

class ConnectorBridge {
  final StreamController<ActorRemoteTransportMessage>
      _actorTransportMessageController = StreamController.broadcast();

  final StreamController<SystemRemoteMessage> _systemMessageController =
      StreamController.broadcast();

  final ActorMessageTransportSerializer _serializer;

  late final ReceivePort _receivePort;

  late final ConnectorSource source;

  Stream<ActorRemoteTransportMessage> get actorMessages =>
      _actorTransportMessageController.stream;

  Stream<SystemRemoteMessage> get systemMessages =>
      _systemMessageController.stream;

  ConnectorBridge(
      ActorMessageTransportSerializer serializer,
      String connectionName,
      dynamic address,
      int port,
      InternetProtocol protocol)
      : _serializer = serializer {
    _receivePort = ReceivePort();

    _receivePort.listen((message) {
      if (message is RemoteMessage) {
        _handleMessage(message);
      }
    });

    source = ConnectorSource(
        connectionName, address, port, protocol, _receivePort.sendPort);
  }

  void _handleMessage(RemoteMessage message) {
    if (message is ActorRemoteMessage) {
      _actorTransportMessageController.sink.add(ActorRemoteTransportMessage(
          message.path,
          message.tag,
          _serializer.serialize(message.tag, message.data)));
    } else if (message is SystemRemoteMessage) {
      _handleSystemRemoteMessage(message);
    }
  }

  void _handleSystemRemoteMessage(SystemRemoteMessage message) {
    _systemMessageController.sink.add(message);
  }

  Future<void> dispose() async {
    await _actorTransportMessageController.close();
    await _systemMessageController.close();

    _receivePort.close();
  }
}
