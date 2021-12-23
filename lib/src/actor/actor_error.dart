part of theater.actor;

class ActorError {
  final ActorError? parent;

  final ActorPath path;

  final Exception exception;

  final StackTrace stackTrace;

  ActorError(this.path, this.exception, this.stackTrace, {this.parent});

  @override
  String toString() {
    if (parent != null) {
      return 'Actor path: ' +
          path.toString() +
          '\n' +
          exception.toString() +
          '\n' +
          stackTrace.toString() +
          '\n' +
          parent.toString();
    } else {
      return path.toString() +
          '\n' +
          exception.toString() +
          '\n' +
          stackTrace.toString();
    }
  }
}
