part of theater.actor;

class ActorError {
  final ActorError? parent;

  final ActorPath path;

  final Exception exception;

  final String _stackTraceString;

  StackTrace get stackTrace => StackTrace.fromString(_stackTraceString);

  ActorError(this.path, this.exception, String stackTrace, {this.parent})
      : _stackTraceString = stackTrace;

  @override
  String toString() {
    if (parent != null) {
      return 'Actor path: ' +
          path.toString() +
          '\n' +
          exception.toString() +
          '\n' +
          _stackTraceString +
          '\n' +
          parent.toString();
    } else {
      return path.toString() +
          '\n' +
          exception.toString() +
          '\n' +
          _stackTraceString;
    }
  }
}
