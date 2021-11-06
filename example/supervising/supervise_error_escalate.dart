import 'package:theater/theater.dart';

// In this example actor with name 'second_test_actor' throw FormatException.
//
// By default, each supervisor actor has a supervisor strategy that handles
// the exception by passing the error to an upstream actor.
//
// In this example, a thrown exception in an actor causes the error to reach the root actor and the actor system,
// the actor system kills all the actors in the system and throw an exception.

// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create child with name 'second_test_actor'
    await context.actorOf('second_test_actor', SecondTestActor());
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Throw exception
    throw FormatException();
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());
}
