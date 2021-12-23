part of theater.util;

/// Class is a base class for all scheduler action context.
///
/// Action context is a class which provides information about an action.
abstract class SchedulerActionContext {
  /// Action call counter.
  final int counter;

  SchedulerActionContext(this.counter);
}
