part of theater.remote;

///
class RemoteSource {
  ///
  final String connectionName;

  ///
  final dynamic address;

  ///
  final int port;

  final SendPort _birdgeSendPort;

  RemoteSource(this.connectionName, this.address, this.port, SendPort sendPort)
      : _birdgeSendPort = sendPort;

  ///
  RemoteActorRef createRemoteRef(ActorPath path) {
    return RemoteActorRef(path, address, port, _birdgeSendPort);
  }
}
