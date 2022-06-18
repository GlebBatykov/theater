part of theater.core;

///
class Subscription<T> {
  final StreamController _cancelController = StreamController.broadcast();

  final StreamSubscription<T> _subscription;

  bool get isPaused => _subscription.isPaused;

  ///
  Stream get onCancel => _cancelController.stream;

  ///
  Subscription.fromStreamSubscription(StreamSubscription<T> subscription)
      : _subscription = subscription;

  ///
  Future<void> cancel() async {
    await _subscription.cancel();

    _cancelController.sink.add(null);
  }

  void onData(void Function(T)? handleData) => _subscription.onData(handleData);

  void onError(Function? handleError) => _subscription.onError(handleError);

  void onDone(void Function()? handleDone) => _subscription.onDone(handleDone);

  void pause([Future<void>? resumeSignal]) => _subscription.pause(resumeSignal);

  void resume() => _subscription.resume();

  Future<E> asFuture<E>([E? futureValue]) => _subscription.asFuture();

  ///
  Future<void> dispose() async {
    await _subscription.cancel();

    await _cancelController.close();
  }
}
