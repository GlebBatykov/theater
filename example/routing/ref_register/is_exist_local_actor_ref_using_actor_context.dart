import 'package:theater/theater.dart';

// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create child actor with name 'second_test_actor'
    await context.actorOf('second_test_actor', SecondTestActor());
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Check is exist actor with path 'test_system/root/user/first_test_actor' in ref register
    var isExist = await context
        .isExistLocalActorRef('test_system/root/user/first_test_actor');

    print(isExist);
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
