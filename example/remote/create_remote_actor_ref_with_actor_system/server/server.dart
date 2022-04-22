import 'package:theater/theater.dart';

import 'server_actor_system_builder.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);

      return;
    });
  }
}

void main() async {
  // Create actor system with actor system builder
  var system = ServerActorSystemBuilder().build();

  // Initialize actor system before work with it
  await system.initialize();

  // Create top level actor with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
