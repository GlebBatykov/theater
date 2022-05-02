part of theater.logging;

class Log {
  String template;

  final LogLevel level;

  final ActorPath actorPath;

  final String message;

  Log(this.template, this.level, this.actorPath, this.message);
}
