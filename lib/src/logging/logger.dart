part of theater.logging;

abstract class Logger {
  final ActorPath path;

  Logger(this.path);

  void info(dynamic object);

  void debug(dynamic object);

  void warning(dynamic object);

  void error(dynamic object);

  void critical(dynamic object);
}
