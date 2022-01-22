import 'package:theater/src/actor_system.dart';
import 'package:theater/src/remote.dart';

// Create actor system builder class
class ClientActorSystemBuilder extends ActorSystemBuilder {
  // Override build method
  @override
  ActorSystem build() {
    var name = 'client_actor_system';

    // Create remote transport configuration.
    var remoteConfiguration = RemoteTransportConfiguration(connectors: [
      TcpConnectorConfiguration(
          name: 'server_actor_system', address: '127.0.0.1', port: 6655)
    ]);

    // Create actor system
    return ActorSystem(name, remoteConfiguration: remoteConfiguration);
  }
}
