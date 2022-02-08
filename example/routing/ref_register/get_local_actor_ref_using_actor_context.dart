// Create first actor class
import 'package:theater/theater.dart';

class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });

    // Create child actor with name 'second_test_actor'
    await context.actorOf('second_test_actor', SecondTestActor());
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Get ref to actor with path 'test_system/root/user/first_test_actor' from ref register
    var ref = await context
        .getLocalActorRef('test_system/root/user/first_test_actor');

    // If ref exist (not null) send message
    ref?.send('Hello, from second actor!');
  }
}

void main(List<String> arguments) async {
  // Create actor system with name 'test_system'
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor' and get ref to it
  await system.actorOf('first_test_actor', FirstTestActor());
}
