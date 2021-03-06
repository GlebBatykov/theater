import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) {
      print(message);

      return;
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system with name 'test_system'
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor' and get ref to it
  await system.actorOf('test_actor', TestActor());

  // Get ref to actor with relative path '../test_actor' from ref register
  // We use here relative path, but absolute path to actor with name 'test_actor' equal - 'test_system/root/user/test_actor'
  var ref = system.getLocalActorRef('../test_actor');

  ref?.send('Hello, from main!');
}
