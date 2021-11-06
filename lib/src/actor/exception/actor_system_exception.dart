part of theater.actor;

class ActorSystemException implements Exception {
  final String? message;

  ActorSystemException({this.message});

  @override
  String toString() {
    if (message != null) {
      return runtimeType.toString() + ': ' + message!;
    } else {
      return super.toString();
    }
  }
}
