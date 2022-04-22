import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      // Print message
      print(message);

      if (message == 'ping') {
        // Send message result
        return MessageResult(data: 'pong');
      } else {
        return null;
      }
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor'
  var ref = await system.actorOf('actor', TestActor());

  // Send message 'Hello, from main!' to actor and get message subscription
  var subscription = ref.sendAndSubscribe('ping');

  // Set onResponse handler
  subscription.onResponse((response) {
    if (response is MessageResult) {
      print(response.data);
    }
  });
}
