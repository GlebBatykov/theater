part of theater.remote;

abstract class ServerConfiguration<S extends SecurityConfiguration> {
  final dynamic address;

  final int port;

  final S? securityConfiguration;

  ServerConfiguration(this.address, this.port, this.securityConfiguration);
}
