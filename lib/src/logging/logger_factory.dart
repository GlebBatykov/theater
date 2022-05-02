part of theater.logging;

abstract class LoggerFactory<L extends Logger> {
  L create(ActorPath path);
}
