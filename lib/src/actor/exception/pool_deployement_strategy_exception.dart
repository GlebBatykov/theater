part of theater.actor;

class PoolDeployementStrategyException implements Exception {
  final String? message;

  PoolDeployementStrategyException({String? message}) : message = message;

  @override
  String toString() {
    if (message != null) {
      return runtimeType.toString() + ': ' + message!;
    } else {
      return super.toString();
    }
  }
}
