part of theater.util;

class CancellationTokenException implements Exception {
  final String? message;

  CancellationTokenException({String? message}) : message = message;

  @override
  String toString() {
    if (message != null) {
      return runtimeType.toString() + ': ' + message!;
    } else {
      return super.toString();
    }
  }
}
