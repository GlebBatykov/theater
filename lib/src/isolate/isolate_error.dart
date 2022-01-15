part of theater.isolate;

class IsolateError {
  final Exception exception;

  final StackTrace stackTrace;

  IsolateError(this.exception, this.stackTrace);
}
