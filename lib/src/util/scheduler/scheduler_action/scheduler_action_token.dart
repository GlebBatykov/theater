part of theater.util;

/// This class is a base class to all scheduler action tokes (like callable action token or repeatedly action token).
abstract class SchedulerActionToken<E extends SchedulerActionEvent,
    R extends SchedulerActionTokenRef> {
  final StreamController<E> _eventController = StreamController.broadcast();

  ReceivePort? _receivePort;

  bool _isDisposed = false;

  /// Ref pointing to scheduler action token ([RepeatedlyActionToken] or [OneShotActionToken]).
  R get ref;

  /// Shows the status of dispose.
  bool get isDisposed => _isDisposed;

  ///
  Stream<E> get stream => _eventController.stream;

  /// Dispose all resources, close all streams.
  ///
  /// After dispose you can no longer use this token.
  Future<void> dispose() async {
    await _eventController.close();

    _isDisposed = true;
  }
}
