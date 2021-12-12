import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    print(context.path);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var actorSystem = ActorSystem('test_system');

  // Initialize actor system before work with it
  await actorSystem.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await actorSystem.actorOf('test_actor', TestActor());
}
