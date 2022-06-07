part of theater.logging;

class LogLevelMiddleware extends LoggerMiddleware {
  @override
  Log handle(Log log) {
    log.template = log.template.replaceAll('&level', log.level.value);

    return log;
  }
}
