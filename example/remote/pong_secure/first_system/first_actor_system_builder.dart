import 'package:theater/theater.dart';

import '../transport_deserializer.dart';
import '../transport_serializer.dart';

// Create actor system builder class
class FirstActorSystemBuilder extends ActorSystemBuilder {
  // Override build method
  @override
  ActorSystem build() {
    var name = 'first_actor_system';

    // Create remote transport configuration.
    // Create in it connector and set serializer and deserializer.
    var remoteConfiguration = RemoteTransportConfiguration(
        serializer: TransportSerializer(),
        deserializer: TransportDeserializer(),
        connectors: [
          TcpConnectorConfiguration(
              name: 'second_actor_system',
              address: '127.0.0.1',
              port: 6655,
              securityConfiguration:
                  TcpConnectorSecurityConfiguration(key: 'sFu9N46GAn5x'))
        ],
        servers: [
          TcpServerConfiguration(
              address: '127.0.0.1',
              port: 6656,
              securityConfiguration:
                  TcpServerSecurityConfiguration(key: 'sFu9N46GAn5x'))
        ]);

    // Create actor system
    return ActorSystem(name, remoteConfiguration: remoteConfiguration);
  }
}
