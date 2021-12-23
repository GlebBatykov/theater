part of theater.core;

class TheaterException implements Exception {
  final String? message;

  TheaterException({String? message}) : message = message;

  @override
  String toString() {
    if (message != null) {
      return runtimeType.toString() + ': ' + message!;
    } else {
      return super.toString();
    }
  }
}
