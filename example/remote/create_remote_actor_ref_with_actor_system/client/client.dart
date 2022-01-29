import 'client_actor_system_builder.dart';

void main() async {
  // Create actor system with actor system builder
  var system = ClientActorSystemBuilder().build();

  // Initialize actor system before work with it
  await system.initialize();

  // Create remote actor ref by connecting with name 'server_actor_system'
  // to actor with actor path 'server_actor_system/root/user/test_actor'
  var ref = system.createRemoteActorRef(
      'server_actor_system', 'server_actor_system/root/user/test_actor');

  // Send message
  ref.send('test_message', 'Hello, from client!');
}
