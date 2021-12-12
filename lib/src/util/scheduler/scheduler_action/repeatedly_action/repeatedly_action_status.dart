part of theater.util;

/// A class that provides information about the status of an repeatedly action.
class RepeatedlyActionStatus extends SchedulerActionStatus {
  /// Status indicating that the action has running.
  static const RepeatedlyActionStatus running =
      RepeatedlyActionStatus._('running');

  /// Status indicating that the action has stopped.
  static const RepeatedlyActionStatus stopped =
      RepeatedlyActionStatus._('stopped');

  const RepeatedlyActionStatus._(String value) : super(value);
}
