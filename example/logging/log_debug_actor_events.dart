import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Print 'Hello, world!'
    print('Hello, world!');
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system',
      loggingProperties: LoggingProperties(
          loggerFactory: TheaterLoggerFactory(),
          enabled: [DebugLevel(lifecycle: true), LogLevel.info]));

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
