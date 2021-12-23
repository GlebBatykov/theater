import 'package:theater/theater.dart';

// Create first actor class
class FirstTestActor extends UntypedActor {
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create actor child with name 'test_child'
    await context.actorOf('test_child', SecondTestActor());

    // Send message to child using relative path
    context.send('../test_child', 'Hello, from parent!');
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  await system.actorOf('test_actor', FirstTestActor());
}
