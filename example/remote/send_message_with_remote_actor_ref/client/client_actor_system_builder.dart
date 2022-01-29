import 'package:theater/theater.dart';

import '../transport_deserializer.dart';
import '../transport_serializer.dart';

// Create actor system builder class for client
class ClientActorSystemBuilder extends ActorSystemBuilder {
  // Override build method
  @override
  ActorSystem build() {
    var name = 'test_client_system';

    // Create remote transport configuration.
    // Create in it connector and set serializer and deserializer.
    var remoteConfiguration = RemoteTransportConfiguration(
        serializer: TransportSerializer(),
        deserializer: TransportDeserializer(),
        connectors: [
          TcpConnectorConfiguration(
              name: 'test_server', address: '127.0.0.1', port: 6655)
        ]);

    // Create actor system
    return ActorSystem(name, remoteConfiguration: remoteConfiguration);
  }
}
