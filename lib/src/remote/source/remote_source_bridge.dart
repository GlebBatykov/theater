part of theater.remote;

class RemoteSourceBridge {
  final StreamController<ActorRemoteTransportMessage> _actorMessageController =
      StreamController.broadcast();

  final StreamController<SystemRemoteTransportMessage>
      _systemMessageController = StreamController.broadcast();

  final ActorMessageTransportSerializer _serializer;

  late final ReceivePort _receivePort;

  late final RemoteSource source;

  Stream<ActorRemoteTransportMessage> get actorMessages =>
      _actorMessageController.stream;

  Stream<SystemRemoteTransportMessage> get systemMessages =>
      _systemMessageController.stream;

  RemoteSourceBridge(ActorMessageTransportSerializer serializer,
      String connectionName, dynamic address, int port)
      : _serializer = serializer {
    _receivePort = ReceivePort();

    _receivePort.listen((message) {
      if (message is RemoteMessage) {
        _handleMessage(message);
      }
    });

    source = RemoteSource(connectionName, address, port, _receivePort.sendPort);
  }

  void _handleMessage(RemoteMessage message) {
    if (message is ActorRemoteMessage) {
      _actorMessageController.sink.add(ActorRemoteTransportMessage(message.path,
          message.tag, _serializer.serialize(message.tag, message.data)));
    } else if (message is SystemRemoteMessage) {
      _systemMessageController.sink.add(SystemRemoteTransportMessage());
    }
  }

  Future<void> dispose() async {
    await _actorMessageController.close();
    await _systemMessageController.close();

    _receivePort.close();
  }
}
