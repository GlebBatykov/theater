part of theater.actor;

class IsolateContext {
  final ReceivePort _receivePort;

  final StreamController<ActorAction> _actionController =
      StreamController.broadcast();

  final StreamController<ActorMessage> _messageController =
      StreamController.broadcast();

  final SendPort supervisorErrorPort;

  final Stream _receiveStream;

  final SendPort supervisorMessagePort;

  Stream<ActorAction> get actions => _actionController.stream;

  Stream<ActorMessage> get messages => _messageController.stream;

  IsolateContext(ReceivePort receivePort, this.supervisorMessagePort,
      this.supervisorErrorPort)
      : _receivePort = receivePort,
        _receiveStream = receivePort.asBroadcastStream() {
    _receiveStream.listen((event) {
      if (event is ActorAction) {
        _actionController.sink.add(event);
      } else if (event is ActorMessage) {
        _messageController.sink.add(event);
      }
    });
  }

  Future<void> dispose() async {
    await _actionController.close();
    await _messageController.close();
    _receivePort.close();
  }
}
