part of theater.util;

///
class RepeatedlyActionToken extends SchedulerActionToken<RepeatedlyActionEvent,
    RepeatedlyActionTokenRef> {
  RepeatedlyActionStatus _status = RepeatedlyActionStatus.running;

  ///
  RepeatedlyActionStatus get status => _status;

  ///
  bool get isRunning => _status == RepeatedlyActionStatus.running;

  ///
  bool get isStoped => _status == RepeatedlyActionStatus.stopped;

  @override
  RepeatedlyActionTokenRef get ref {
    if (_receivePort == null) {
      _receivePort = ReceivePort();

      _receivePort!.listen((message) {
        if (message is RepeatedlyActionTokenEvent) {
          _handleRepeatedlyActionTokenEvent(message);
        }
      });
    }

    return RepeatedlyActionTokenRef(_receivePort!.sendPort);
  }

  void _handleRepeatedlyActionTokenEvent(RepeatedlyActionTokenEvent event) {
    if (event is RepeatedlyActionTokenGetStatus) {
      event.feedbackPort.send(RepeatedlyActionTokenStatus(_status));
    } else if (event is RepeatedlyActionTokenStop) {
      stop();
    } else if (event is RepeatedlyActionTokenResume) {
      resume();
    }
  }

  ///
  StreamSubscription<RepeatedlyActionEvent> addOnStopListener(
      void Function() listener) {
    return _eventController.stream
        .where((event) => event is RepeatedlyActionStop)
        .listen((event) => listener());
  }

  ///
  StreamSubscription<RepeatedlyActionEvent> addOnResumeListener(
      void Function() listener) {
    return _eventController.stream
        .where((event) => event is RepeatedlyActionResume)
        .listen((event) => listener());
  }

  ///
  void stop() {
    _eventController.sink.add(RepeatedlyActionStop());

    _status = RepeatedlyActionStatus.stopped;
  }

  ///
  void resume() {
    _eventController.sink.add(RepeatedlyActionResume());

    _status = RepeatedlyActionStatus.running;
  }
}
