part of theater.dispatch;

//
class CancellationTokenRef extends Ref {
  CancellationTokenRef(SendPort sendPort) : super(sendPort);

  /// Sends cancel event to the instance of [CancellationToken] refers to.
  Future<void> cancel() async {
    var value = await isCanceled();

    if (!value) {
      _sendPort.send(RemoteCancelToken());
    } else {
      throw CancellationTokenRefException(
          message: 'token has already been canceled.');
    }
  }

  ///
  Future<bool> isCanceled() async {
    var receivePort = ReceivePort();

    _sendPort.send(GetTokenStatus(receivePort.sendPort));

    var event = await receivePort.first as TokenStatus;

    receivePort.close();

    return event.status;
  }
}
