part of theater.dispatch;

/// Сlass used to track the state of a message sent to another actor, receive a response to the sent message.
class MessageSubscription {
  final ReceivePort _receivePort;

  final StreamController<MessageResponse> _responseController =
      StreamController.broadcast();

  bool _isCanceled = false;

  bool _isMultiple = false;

  /// Used to read the message state as from a stream.
  Stream<MessageResponse> get stream => _responseController.stream;

  /// Displays the current status of the subscription.
  bool get isCanceled => _isCanceled;

  /// Displays whether a subscription can accept more than one reply per message.
  bool get isMultiple => _isMultiple;

  MessageSubscription(ReceivePort receivePort) : _receivePort = receivePort {
    _receivePort.listen((message) {
      if (message is MessageResponse) {
        _responseController.sink.add(message);

        if (!_isMultiple) {
          cancel();
        }
      }
    });
  }

  /// Subscribes to the reply about the status of the sent message.
  void onResponse(void Function(MessageResponse response) handler) {
    _responseController.stream.listen(handler);
  }

  /// Creates the version of the current subscription that can accept more than one response per message sent.
  MessageSubscription asMultipleSubscription() {
    _isMultiple = true;

    return this;
  }

  ///
  Future<T> getFirstResult<T>() {
    return stream
        .firstWhere((element) => element is MessageResult)
        .then((value) {
      return (value as MessageResult).data;
    });
  }

  /// Cancels subscription, closes [ReceivePort] and all streams.
  void cancel() {
    _receivePort.close();
    _responseController.close();

    _isCanceled = true;
  }
}
