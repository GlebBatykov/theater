part of theater.util;

/// A class that allows you to create actions that are executed at a certain frequency, as well as, if necessary, cancel them.
///
/// Everything that this class does can be implemented independently using [Timer] and [Future.delayed]. This class is a comfortable abstraction.
class Scheduler {
  final List<RepeatedlyAction> _repeatedlyActions = [];

  final List<OneShotAction> _oneShotActions = [];

  /// Schedules and runs repeatedly action.
  ///
  /// Delays [initialDelay] before runs action.
  /// Calls action with an interval of [interval].
  ///
  /// Binds scheduled action with [actionToken].
  ///
  /// If you stopped action calls [onStop] callback.
  /// If you resumed action calls [onResume] callback.
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
        actionToken: actionToken,
        initialDelay: initialDelay,
        onStop: onStop,
        onResume: onResume);

    repeatedlyAction.start();

    _repeatedlyActions.add(repeatedlyAction);
  }

  /// Schedules one shot action.
  ///
  /// Binds scheduled action with [actionToken].
  void scheduleOneShotAction(
      {required void Function(OneShotActionContext) action,
      required OneShotActionToken actionToken}) {
    var oneShotAction = OneShotAction(action: action, actionToken: actionToken);

    _oneShotActions.add(oneShotAction);
  }
}
