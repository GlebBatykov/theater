part of theater.util;

/// A class that allows you to create actions that are executed at a certain frequency, as well as, if necessary, cancel them.
///
/// Everything that this class does can be implemented independently using [Timer] and [Future.delayed]. This class is a comfortable abstraction.
class Scheduler {
  /// Creates an action that is performed at regular intervals.
  ///
  /// The interval is set by the value [interval].
  /// The initial delay (fires once when the action starts) is set by the value [initDelay].
  /// To undo a repeat action, you must use [CancellationToken]. One [CancellationToken] can be used by many actions.
  void scheduleActionRepeatedly(
      {Duration? initDelay,
      required Duration? interval,
      required void Function() action,
      CancellationToken? cancellationToken}) {
    if (cancellationToken != null) {
      if (!cancellationToken.isCanceled) {
        _runAction(initDelay, interval, action, cancellationToken);
      }
    } else {
      _runAction(initDelay, interval, action, cancellationToken);
    }
  }

  void _runAction(Duration? initDelay, Duration? interval,
      void Function() action, CancellationToken? cancellationToken) {
    Future.delayed(initDelay ?? Duration(), () {
      var timer = Timer.periodic(interval ?? Duration(), (timer) {
        action();
      });

      cancellationToken?.addOnCancelListener(() {
        timer.cancel();
      });
    });
  }
}
