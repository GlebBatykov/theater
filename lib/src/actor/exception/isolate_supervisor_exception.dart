part of theater.actor;

class IsolateSupervisorException implements Exception {
  final String? message;

  IsolateSupervisorException({String? message}) : message = message;

  @override
  String toString() {
    if (message != null) {
      return runtimeType.toString() + ': ' + message!;
    } else {
      return super.toString();
    }
  }
}
