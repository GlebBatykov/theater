import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor' and get ref to him
  var ref = await system.actorOf('test_actor', TestActor());
}
