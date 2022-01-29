part of theater.dispatch;

// This class is a base class to all Ref classes
abstract class Ref {
  final SendPort _sendPort;

  Ref(SendPort sendPort) : _sendPort = sendPort;
}
