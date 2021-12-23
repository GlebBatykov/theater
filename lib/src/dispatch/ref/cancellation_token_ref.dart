part of theater.dispatch;

//
class CancellationTokenRef extends Ref {
  final SendPort _tokenSendPort;

  CancellationTokenRef(SendPort tokenSendPort) : _tokenSendPort = tokenSendPort;

  /// Sends cancel event to the instance of [CancellationToken] refers to.
  Future<void> cancel() async {
    var value = await isCanceled();

    if (!value) {
      _tokenSendPort.send(RemoteCancelToken());
    } else {
      throw CancellationTokenRefException(
          message: 'token has already been canceled.');
    }
  }

  ///
  Future<bool> isCanceled() async {
    var receivePort = ReceivePort();

    _tokenSendPort.send(GetTokenStatus(receivePort.sendPort));

    var event = await receivePort.first as TokenStatus;

    receivePort.close();

    return event.status;
  }
}
