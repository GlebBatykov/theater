part of theater.system_actors;

class ConnectorSource {
  final String connectionName;

  final dynamic address;

  final int port;

  final InternetProtocol protocol;

  final SendPort birdgeSendPort;

  OutgoingConnection? _connection;

  OutgoingConnection get connection {
    if (_connection == null) {
      return _connection = OutgoingConnection(
          address, port, protocol, connectionName, birdgeSendPort);
    } else {
      return _connection!;
    }
  }

  ConnectorSource(this.connectionName, this.address, this.port, this.protocol,
      SendPort sendPort)
      : birdgeSendPort = sendPort;

  RemoteActorRef createRemoteRef(ActorPath path) {
    return RemoteActorRef(path, address, port, birdgeSendPort);
  }
}
