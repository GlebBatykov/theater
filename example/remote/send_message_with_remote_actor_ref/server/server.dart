import 'package:theater/theater.dart';

import '../test_message.dart';
import 'server_actor_system_builder.dart';

// Create actor which will receive messages
class ServerActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all Message type messages which actor received
    context.receive<TestMessage>((message) async {
      print(message.data);

      return;
    });
  }
}

void main() async {
  // Create actor system with actor system builder
  var system = ServerActorSystemBuilder().build();

  // Initialize actor system before work with it
  await system.initialize();

  // Create top level actor with name 'test_server_actor'
  await system.actorOf('test_server_actor', ServerActor());
}
