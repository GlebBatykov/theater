import 'package:theater/theater.dart';

import '../ping.dart';
import '../pong.dart';
import 'second_actor_system_builder.dart';

// Create actor class
class TestActor extends UntypedActor {
  late final RemoteActorRef _ref;

  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    var connectionName = 'first_actor_system';

    var remoteActorPath = 'first_actor_system/root/user/test_actor';

    // Set handler to all Ping type messages which actor received
    context.receive<Ping>((message) async {
      print(message.data);

      // Send message with tag 'pong'
      _ref.send('pong', Pong('Pong message from second actor system!'));

      return;
    });

    // Create remote actor ref by connecting with name 'first_actor_system'
    // to actor with actor path 'first_actor_system/root/user/test_actor'
    _ref = await context.createRemoteActorRef(connectionName, remoteActorPath);
  }
}

void main() async {
  // Create actor system with actor system builder
  var system = SecondActorSystemBuilder().build();

  // Initialize actor system before work with it
  await system.initialize();

  // Create top level actor with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
