import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    print('Hello, from test actor!');
  }
}

void main(List<String> arguments) async {
  // Create actor system with name 'test_system'
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor' and get ref to it
  await system.actorOf('test_actor', TestActor());

  // Check if there is an actor with relative path '../test_actor' in the registry
  // We use here relative path, but absolute path to actor with name 'test_actor' equal - 'test_system/root/user/test_actor'
  var isExist = system.isExistLocalActorRef('../test_actor');

  print(isExist);
}
