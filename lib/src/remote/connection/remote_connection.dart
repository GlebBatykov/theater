part of theater.remote;

abstract class RemoteConnection {
  ///
  final dynamic address;

  ///
  final int port;

  ///
  final InternetProtocol protocol;

  RemoteConnection(this.address, this.port, this.protocol);
}
