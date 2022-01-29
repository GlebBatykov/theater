part of theater.core;

abstract class TheaterException implements Exception {
  final String? message;

  TheaterException([this.message]);

  @override
  String toString() {
    if (message != null) {
      return runtimeType.toString() + ': ' + message!;
    } else {
      return super.toString();
    }
  }
}
