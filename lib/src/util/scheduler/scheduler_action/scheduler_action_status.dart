part of theater.util;

/// Class is a base class for all scheduler action status classes.
///
/// A class that provides information about the status of an action.
abstract class SchedulerActionStatus {
  /// Status of action.
  final String value;

  const SchedulerActionStatus(this.value);

  @override
  bool operator ==(other) {
    if (other is RepeatedlyActionStatus) {
      return value == other.value;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    var hashCode = super.hashCode;

    return hashCode;
  }
}
