part of theater.actor;

class ActorError {
  final ActorError? parent;

  final ActorPath path;

  final Object object;

  final StackTrace stackTrace;

  ActorError(this.path, this.object, this.stackTrace, {this.parent});

  @override
  String toString() {
    if (parent != null) {
      return 'Actor path: ' +
          path.toString() +
          '\n' +
          object.toString() +
          '\n' +
          stackTrace.toString() +
          '\n' +
          parent.toString();
    } else {
      return path.toString() +
          '\n' +
          object.toString() +
          '\n' +
          stackTrace.toString();
    }
  }
}
