part of theater.util;

/// A class that allows you to create actions that are executed at a certain frequency, as well as, if necessary, cancel them.
///
/// Everything that this class does can be implemented independently using [Timer] and [Future.delayed]. This class is a comfortable abstraction.
class Scheduler {
  final List<RepeatedlyAction> _repeatedlyActions = [];

  final List<OneShotAction> _oneShotActions = [];

  void scheduleRepeatedlyAction(
      {Duration? initialDelay,
      required Duration interval,
      required RepeatedlyActionCallback action,
      RepeatedlyActionToken? actionToken,
      RepeatedlyActionCallback? onStop,
      RepeatedlyActionCallback? onResume}) {
    var repeatedlyAction = RepeatedlyAction(
        interval: interval,
        action: action,
        initialDelay: initialDelay,
        onStop: onStop,
        onResume: onResume);

    repeatedlyAction.start();

    _repeatedlyActions.add(repeatedlyAction);
  }

  void scheduleOneShotAction(
      {required void Function(OneShotActionContext) action,
      required OneShotActionToken actionToken}) {
    var oneShotAction = OneShotAction(action: action, actionToken: actionToken);

    _oneShotActions.add(oneShotAction);
  }

  /*
  /// Creates an action that is performed at regular intervals.
  ///
  /// The interval is set by the value [interval].
  /// The initial delay (fires once when the action starts) is set by the value [initDelay].
  /// To undo a repeat action, you must use [CancellationToken]. One [CancellationToken] can be used by many actions.
  void scheduleActionRepeatedly(
      {Duration? initDelay,
      required Duration? interval,
      required void Function(RepeatedlyActionContext) action,
      CancellationToken? cancellationToken,
      void Function(RepeatedlyActionContext)? onCancel}) {
    if (cancellationToken != null) {
      if (!cancellationToken.isCanceled) {
        _runAction(initDelay, interval, action, cancellationToken, onCancel);
      }
    } else {
      _runAction(initDelay, interval, action, cancellationToken, onCancel);
    }
  }

  void _runAction(
      Duration? initDelay,
      Duration? interval,
      void Function(RepeatedlyActionContext) action,
      CancellationToken? cancellationToken,
      void Function(RepeatedlyActionContext)? onCancel) {
    var number = 0;

    Future.delayed(initDelay ?? Duration(), () {
      var timer = Timer.periodic(interval ?? Duration(), (timer) {
        number++;

        action(RepeatedlyActionContext(number));
      });

      cancellationToken?.addOnCancelListener(() {
        timer.cancel();

        onCancel?.call(RepeatedlyActionContext(number));
      });
    });
  }
  */
}
