import 'package:theater/theater.dart';

// Create actor system builder class
class ServerActorSystemBuilder extends ActorSystemBuilder {
  // Override build method
  @override
  ActorSystem build() {
    var name = 'server_actor_system';

    // Create remote transport configuration.
    var remoteConfiguration = RemoteTransportConfiguration(
        servers: [TcpServerConfiguration(name: 'server', port: 6655)]);

    // Create actor system
    return ActorSystem(name, remoteConfiguration: remoteConfiguration);
  }
}
