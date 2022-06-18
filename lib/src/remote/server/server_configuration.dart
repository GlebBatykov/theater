part of theater.remote;

abstract class ServerConfiguration<S extends SecurityConfiguration> {
  final String name;

  final int port;

  final S? securityConfiguration;

  ServerConfiguration(this.name, this.port, this.securityConfiguration);
}
