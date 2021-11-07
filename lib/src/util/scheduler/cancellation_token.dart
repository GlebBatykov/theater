part of theater.util;

/// Class used to cancel various things. For example, to undo a action redo in [Scheduler].
class CancellationToken {
  final StreamController<CancelEvent> _streamController =
      StreamController.broadcast();

  bool _isCanceled = false;

  /// Displays the current status of the token.
  bool get isCanceled => _isCanceled;

  /// Cancels token and send cancel event to all token subscribers.
  void cancel({Duration? delay}) {
    if (delay != null) {
      Future.delayed(delay, () {
        _streamController.sink.add(CancelEvent());
        _isCanceled = true;
      });
    } else {
      _streamController.sink.add(CancelEvent());
      _isCanceled = true;
    }
  }

  /// Subscibe to this cancellation token.
  StreamSubscription<CancelEvent> addOnCancelListener(
      void Function() listener) {
    return _streamController.stream.listen((event) => listener());
  }
}
