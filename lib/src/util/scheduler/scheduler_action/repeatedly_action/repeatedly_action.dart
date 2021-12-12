part of theater.util;

typedef RepeatedlyActionCallback = void Function(RepeatedlyActionContext);

class RepeatedlyAction extends SchedulerAction {
  final StreamController<RepeatedlyActionEvent> _streamController =
      StreamController();

  final Duration? _initialDelay;

  final Duration _interval;

  final RepeatedlyActionCallback _action;

  final RepeatedlyActionCallback? _onStop;

  final RepeatedlyActionCallback? _onResume;

  final RepeatedlyActionToken? _actionToken;

  Timer? timer;

  RepeatedlyAction(
      {required Duration interval,
      required RepeatedlyActionCallback action,
      Duration? initialDelay,
      RepeatedlyActionCallback? onStop,
      RepeatedlyActionCallback? onResume,
      RepeatedlyActionToken? actionToken})
      : _interval = interval,
        _action = action,
        _initialDelay = initialDelay,
        _onStop = onStop,
        _onResume = onResume,
        _actionToken = actionToken {
    _actionToken?.addOnStopListener(() => stop());

    _actionToken?.addOnResumeListener(() => resume());

    _streamController.stream.listen((event) {
      _handleRepeatedlyActionEvent(event);
    });
  }

  void _handleRepeatedlyActionEvent(RepeatedlyActionEvent event) {
    if (event is RepeatedlyActionStop) {
      stop();
    } else if (event is RepeatedlyActionResume) {
      resume();
    }
  }

  void start() {
    timer?.cancel();

    Future.delayed(_initialDelay ?? Duration(), () {
      timer = Timer.periodic(_interval, (timer) {
        var context = RepeatedlyActionContext(counter);

        _action(context);

        counter++;
      });
    });
  }

  void stop() {
    timer?.cancel();

    _onStop?.call(RepeatedlyActionContext(counter));
  }

  void resume() {
    if (timer != null && !timer!.isActive) {
      _onResume?.call(RepeatedlyActionContext(counter));
    }

    start();
  }
}
