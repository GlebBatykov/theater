part of theater.logging;

class DebugLevel extends LogLevel {
  final bool lifecycle;

  final bool remote;

  DebugLevel({this.lifecycle = false, this.remote = false}) : super._('debug');
}
