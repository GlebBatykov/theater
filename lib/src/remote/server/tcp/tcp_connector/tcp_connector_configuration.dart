part of theater.remote;

class TcpConnectorConfiguration
    extends ConnectorConfiguration<TcpConnectorSecurityConfiguration> {
  TcpConnectorConfiguration(
      {required String name,
      required dynamic address,
      required int port,
      Duration? timeout,
      TcpConnectorSecurityConfiguration? securityConfiguration,
      Duration? reconnectTimeout,
      int? reconnectDelay})
      : super(name, address, port, timeout, securityConfiguration,
            reconnectTimeout, reconnectDelay);
}
