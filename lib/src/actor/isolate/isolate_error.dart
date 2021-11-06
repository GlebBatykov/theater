part of theater.actor;

class IsolateError {
  final Exception exception;

  final String _stackTraceString;

  StackTrace get stackTrace => StackTrace.fromString(_stackTraceString);

  IsolateError(this.exception, String stackTrace)
      : _stackTraceString = stackTrace;
}
