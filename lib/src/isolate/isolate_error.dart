part of theater.isolate;

class IsolateError {
  final Object object;

  final StackTrace stackTrace;

  IsolateError(this.object, this.stackTrace);
}
