part of theater.logging;

class ActorPathMiddleware extends LoggerMiddleware {
  @override
  Log handle(Log log) {
    log.template =
        log.template.replaceAll('&actor_path', log.actorPath.toString());

    return log;
  }
}
