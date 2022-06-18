import 'package:theater/theater.dart';

import '../ping.dart';
import '../pong.dart';
import 'first_actor_system_builder.dart';

// Create actor class
class TestActor extends UntypedActor {
  late final RemoteActorRef _ref;

  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    var connectioName = 'second_actor_system';

    var remoteActorPath = 'second_actor_system/root/user/test_actor';

    // Set handler to all Pong type messages which actor received
    context.receive<Pong>((message) async {
      print(message.data);

      return;
    });

    // Create remote actor ref by connecting with name 'second_actor_system'
    // to actor with actor path 'second_actor_system/root/user/test_actor'
    _ref = await context.createRemoteActorRef(connectioName, remoteActorPath);

    // Send message with tag 'ping'
    _ref.send('ping', Ping('Ping message from first actor system!'));
  }
}

void main() async {
  // Create actor system with actor system builder
  var system = FirstActorSystemBuilder().build();

  // Initialize actor system before work with it
  await system.initialize();

  // Create top level actor with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
