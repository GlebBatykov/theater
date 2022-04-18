import 'dart:async';

import 'package:theater/theater.dart';

// Create first test actor class
class FirstTestActor extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    // Create router actor
    await context.actorOf('test_router', TestRouter());

    // Send message to router
    context.send('../test_router', 'Second hello!');

    // Send message to second without router
    context.send('../test_router/second_test_actor', 'First hello!');
  }
}

// Create router class
class TestRouter extends GroupRouterActor {
  // Override createDeployementStrategy method, configurate group router actor
  @override
  GroupDeployementStrategy createDeployementStrategy() {
    return GroupDeployementStrategy(
        routingStrategy: GroupRoutingStrategy.broadcast,
        group: [
          ActorInfo(name: 'second_test_actor', actor: SecondTestActor()),
          ActorInfo(name: 'third_test_actor', actor: ThirdTestActor())
        ]);
  }
}

// Create second test actor class
class SecondTestActor extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print('Second actor received message: ' + message);

      return;
    });
  }
}

// Create third test actor class
class ThirdTestActor extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print('Third actor received message: ' + message);

      return;
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var actorSystem = ActorSystem('test_system');

  // Initialize actor system before work with it
  await actorSystem.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  await actorSystem.actorOf('first_test_actor', FirstTestActor());
}
