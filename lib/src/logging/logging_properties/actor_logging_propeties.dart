part of theater.logging;

class ActorLoggingProperties extends LoggingProperties {
  final LoggingProperties? actorLoggerProperties;

  ActorLoggingProperties(
      {List<LogLevel>? enabled,
      this.actorLoggerProperties,
      required LoggerFactory loggerFactory})
      : super(enabled: enabled, loggerFactory: loggerFactory);

  ActorLoggingProperties.fromLoggingProperties(
      LoggingProperties loggingProperties,
      [this.actorLoggerProperties])
      : super(
            loggerFactory: loggingProperties.loggerFactory,
            enabled: loggingProperties.enabled);
}
