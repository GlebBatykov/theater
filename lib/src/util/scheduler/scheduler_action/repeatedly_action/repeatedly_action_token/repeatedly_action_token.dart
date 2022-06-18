part of theater.util;

/// Used in scheduler to stop and resume repeatedly actions.
class RepeatedlyActionToken extends SchedulerActionToken<RepeatedlyActionEvent,
    RepeatedlyActionTokenRef> {
  RepeatedlyActionStatus _status = RepeatedlyActionStatus.running;

  /// Displays status actions which bonded to this token.
  RepeatedlyActionStatus get status => _status;

  /// Displays status actions which bonded to this token.
  ///
  /// If actions is running return true, else return false.
  bool get isRunning => _status == RepeatedlyActionStatus.running;

  /// Displays status actions which bonded to this token.
  ///
  /// If actions is stoped return true, else return false.
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
    } else if (event is RepeatedlyActionTokenChangeInterval) {
      changeInterval(event.interval);
    }
  }

  /// Add listener to stop event.
  StreamSubscription<RepeatedlyActionEvent> addOnStopListener(
      void Function() listener) {
    return _eventController.stream
        .where((event) => event is RepeatedlyActionStop)
        .listen((event) => listener());
  }

  /// Add listener to resume event.
  StreamSubscription<RepeatedlyActionEvent> addOnResumeListener(
      void Function() listener) {
    return _eventController.stream
        .where((event) => event is RepeatedlyActionResume)
        .listen((event) => listener());
  }

  /// Stops all action which bonded with this token.
  void stop() {
    _eventController.sink.add(RepeatedlyActionStop());

    _status = RepeatedlyActionStatus.stopped;
  }

  /// Resumes all action which bonded with this token.
  void resume() {
    _eventController.sink.add(RepeatedlyActionResume());

    _status = RepeatedlyActionStatus.running;
  }

  void changeInterval(Duration interval) {
    _eventController.sink.add(RepeatedlyActionChangeInterval(interval));
  }
}
