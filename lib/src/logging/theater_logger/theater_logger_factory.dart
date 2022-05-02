part of theater.logging;

class TheaterLoggerFactory extends LoggerFactory<TheaterLogger> {
  final String template;

  TheaterLoggerFactory(this.template);

  @override
  TheaterLogger create(ActorPath path) {
    return TheaterLogger(template, path);
  }
}
