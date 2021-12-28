part of theater.actor;

class IsolateError {
  final Exception exception;

  final StackTrace stackTrace;

  IsolateError(this.exception, this.stackTrace);
}
