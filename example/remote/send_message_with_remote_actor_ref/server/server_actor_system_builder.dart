import 'package:theater/theater.dart';

import '../transport_deserializer.dart';
import '../transport_serializer.dart';

// Create actor system builder class for server
class ServerActorSystemBuilder extends ActorSystemBuilder {
  // Override build method
  @override
  ActorSystem build() {
    var name = 'test_server_system';

    // Create remote transport configuration.
    // Create in it server and set serializer and deserializer.
    var remoteConfiguration = RemoteTransportConfiguration(
        serializer: TransportSerializer(),
        deserializer: TransportDeserializer(),
        servers: [TcpServerConfiguration(name: 'server', port: 6655)]);

    // Create actor system
    return ActorSystem(name, remoteConfiguration: remoteConfiguration);
  }
}
