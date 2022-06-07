part of theater.logging;

class DebugLevel extends LogLevel {
  final bool lifecycle;

  DebugLevel({this.lifecycle = false}) : super._('debug');
}
