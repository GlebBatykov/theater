part of theater.util;

typedef RepeatedlyActionCallback = void Function(
    RepeatedlyActionContext context);

class RepeatedlyAction extends SchedulerAction {
  final StreamController<RepeatedlyActionEvent> _streamController =
      StreamController();

  final Duration? _initialDelay;

  final RepeatedlyActionCallback _action;

  final RepeatedlyActionCallback? _onStop;

  final RepeatedlyActionCallback? _onResume;

  final RepeatedlyActionToken? _actionToken;

  Duration _interval;

  Timer? timer;

  StreamSubscription? _initialDelaySubscription;

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
    _actionToken?.stream.listen((event) => _streamController.sink.add(event));

    _streamController.stream.listen((event) {
      _handleRepeatedlyActionEvent(event);
    });
  }

  void _handleRepeatedlyActionEvent(RepeatedlyActionEvent event) {
    if (event is RepeatedlyActionStop) {
      _stop();
    } else if (event is RepeatedlyActionResume) {
      _resume();
    } else if (event is RepeatedlyActionChangeInterval) {
      _changeInterval(event.interval);
    }
  }

  void start() async {
    timer?.cancel();

    if (_initialDelay != null) {
      await _initialDelaySubscription?.cancel();

      _initialDelaySubscription =
          Future.delayed(_initialDelay!).asStream().listen((event) async {
        timer = Timer.periodic(_interval, _runTimer);

        await _initialDelaySubscription?.cancel();
      });
    } else {
      timer = Timer.periodic(_interval, _runTimer);
    }
  }

  void _runTimer(Timer timer) {
    var context = RepeatedlyActionContext(counter);

    _action(context);

    counter++;
  }

  void _stop() async {
    timer?.cancel();

    await _initialDelaySubscription?.cancel();

    _onStop?.call(RepeatedlyActionContext(counter));
  }

  void _resume() {
    if (timer != null && !timer!.isActive) {
      _onResume?.call(RepeatedlyActionContext(counter));
    }

    start();
  }

  void _changeInterval(Duration interval) {
    timer?.cancel();

    _interval = interval;

    timer = Timer.periodic(_interval, _runTimer);
  }
}
