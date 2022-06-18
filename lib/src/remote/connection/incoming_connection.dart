part of theater.remote;

class IncomingConnection extends RemoteConnection {
  ///
  final String serverName;

  IncomingConnection(
      super.address, super.port, super.protocol, this.serverName);
}
