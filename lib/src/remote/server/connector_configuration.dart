part of theater.remote;

class ConnectorConfiguration<S extends SecurityConfiguration> {
  final String name;

  final dynamic address;

  final int port;

  final Duration? timeout;

  final S? securityConfiguration;

  final Duration? reconnectTimeout;

  final double? reconnectDelay;

  final ConnectorSupervisingStrategy supervisingStrategy;

  ConnectorConfiguration(
      this.name,
      this.address,
      this.port,
      this.timeout,
      this.securityConfiguration,
      this.reconnectTimeout,
      this.reconnectDelay,
      this.supervisingStrategy);
}
