import 'package:theater/theater.dart';

// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);
    });
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  late LocalActorRef _ref;

  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Get ref from actor store
    _ref = context.store.get<LocalActorRef>('first_test_actor_ref');

    // Send message
    _ref.send('Hello, from second test actor!');
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  var ref = await system.actorOf('first_test_actor', FirstTestActor());

  var data = <String, dynamic>{'first_test_actor_ref': ref};

  // Create top-level actor in actor system with name 'second_test_actor'
  await system.actorOf('second_test_actor', SecondTestActor(), data: data);
}
