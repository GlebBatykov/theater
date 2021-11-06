part of theater.dispatch;

class ActorRefException implements Exception {
  final String? message;

  ActorRefException({String? message}) : message = message;

  @override
  String toString() {
    if (message != null) {
      return runtimeType.toString() + ': ' + message!;
    } else {
      return super.toString();
    }
  }
}
