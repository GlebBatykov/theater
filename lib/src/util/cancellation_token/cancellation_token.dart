part of theater.util;

/// Class used to cancel various things. For example, to undo a action redo in [Scheduler].
class CancellationToken {
  final StreamController<CancelEvent> _streamController =
      StreamController.broadcast();

  ReceivePort? _receivePort;

  bool _isCanceled = false;

  bool _isDisposed = false;

  /// Displays the current status of the token.
  ///
  /// If the method [cancel] was called at least once [isCanceled] field will be true.
  bool get isCanceled => _isCanceled;

  /// Shows the status of dispose.
  bool get isDisposed => _isDisposed;

  /// The first time it is accessed, it creates instance of [ReceivePort] for receiving cancel events from other isolates.
  ///
  /// If instance of [ReceivePort] was created he dispose in [dispose] method.
  CancellationTokenRef get ref {
    if (_receivePort == null) {
      _receivePort = ReceivePort();

      _receivePort!.listen((message) {
        if (message is CancellationTokenEvent) {
          _handleCancellationTokenEvent(message);
        }
      });
    }

    return CancellationTokenRef(_receivePort!.sendPort);
  }

  void _handleCancellationTokenEvent(CancellationTokenEvent event) {
    if (event is RemoteCancelToken) {
      cancel();
    } else if (event is GetTokenStatus) {
      event.feedbackPort.send(TokenStatus(_isCanceled));
    }
  }

  /// Cancels token and send cancel event to all token subscribers.
  void cancel({Duration? delay}) {
    if (!_isDisposed) {
      if (!_isCanceled) {
        if (delay != null) {
          Future.delayed(delay, () {
            _streamController.sink.add(CancelEvent());
            _isCanceled = true;
          });
        } else {
          _streamController.sink.add(CancelEvent());
          _isCanceled = true;
        }
      } else {
        throw CancellationTokenException(
            message: 'token has already been canceled.');
      }
    } else {
      throw CancellationTokenException(
          message: 'the token cannot be canceled after dispose.');
    }
  }

  /// Subscibe to this cancellation token.
  StreamSubscription<CancelEvent> addOnCancelListener(
      void Function() listener) {
    return _streamController.stream.listen((event) => listener());
  }

  /// Closes all stream and closes instance of [ReceivePort] if you accessed the getter [ref].
  Future<void> dispose() async {
    _receivePort?.close();
    await _streamController.close();

    _isDisposed = true;
  }
}
