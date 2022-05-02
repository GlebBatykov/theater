part of theater.logging;

class MessageMiddleware extends LoggerMiddleware {
  @override
  Log handle(Log log) {
    log.template = log.template.replaceAll('&message', log.message);

    return log;
  }
}
