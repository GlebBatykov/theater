// ignore_for_file: unused_local_variable

import 'package:theater/theater.dart';

// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create child actor with name 'second_test_actor' and get ref to him
    var ref = context.actorOf('second_test_actor', SecondTestActor());
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor' and get ref to him
  await system.actorOf('first_test_actor', FirstTestActor());
}
