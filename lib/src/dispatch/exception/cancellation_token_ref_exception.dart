part of theater.dispatch;

class CancellationTokenRefException implements Exception {
  final String? message;

  CancellationTokenRefException({String? message}) : message = message;

  @override
  String toString() {
    if (message != null) {
      return runtimeType.toString() + ': ' + message!;
    } else {
      return super.toString();
    }
  }
}
