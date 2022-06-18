import 'package:theater/theater.dart';

import '../test_message.dart';
import 'client_actor_system_builder.dart';

// Create actor who will send messages
class ClientActor extends UntypedActor {
  late final RemoteActorRef _ref;

  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    var connectionName = 'test_server';

    var remoteActorPath = 'test_server_system/root/user/test_server_actor';

    // Create remote actor ref by connecting with name 'test_server'
    // to actor with actor path 'test_server_system/root/user/test_server_actor'
    _ref = await context.createRemoteActorRef(connectionName, remoteActorPath);

    // Send message with tag 'test_message'
    _ref.send('test_message', TestMessage('Hello, from client!'));
  }
}

void main() async {
  // Create actor system with actor system builder
  var system = ClientActorSystemBuilder().build();

  // Initialize actor system before work with it
  await system.initialize();

  // Create top level actor with name 'test_client_actor'
  await system.actorOf('test_client_actor', ClientActor());
}
