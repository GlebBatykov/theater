import 'package:theater/theater.dart';

// Create first actor class
class FirstTestActor extends UntypedActor {
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create child with name 'second'
    await context.actorOf('second', SecondTestActor());

    // Send routing message and get message subscription
    var subscription =
        context.sendAndSubscribe('../second', 'Hello, from actor!');

    // Set subscription onResponse handler
    subscription.onResponse((response) {
      if (response is MessageResult) {
        print(response.data);
      }
    });
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      // Send message result
      return MessageResult(data: 'Hello, from second actor!');
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', FirstTestActor());
}
