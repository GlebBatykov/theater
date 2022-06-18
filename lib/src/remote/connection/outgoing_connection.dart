part of theater.remote;

class OutgoingConnection extends RemoteConnection {
  ///
  final String connectionName;

  final SendPort _bridgeSendPort;

  OutgoingConnection(super.address, super.port, super.protocol,
      this.connectionName, SendPort bridgeSendPort)
      : _bridgeSendPort = bridgeSendPort;

  ///
  RemoteActorRef createRemoteActorRef(ActorPath path) {
    return RemoteActorRef(path, address, port, _bridgeSendPort);
  }
}
