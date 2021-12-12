part of theater.routing;

class RemoteAddress {
  final InternetProtocol protocol;

  final String host;

  final int port;

  RemoteAddress(this.host, this.port, {this.protocol = InternetProtocol.tcp});
}
