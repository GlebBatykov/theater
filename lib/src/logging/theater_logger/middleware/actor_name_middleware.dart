part of theater.logging;

class ActorNameMiddleware extends LoggerMiddleware {
  @override
  Log handle(Log log) {
    log.template = log.template.replaceAll('&actor_name', log.actorPath.name);

    return log;
  }
}
