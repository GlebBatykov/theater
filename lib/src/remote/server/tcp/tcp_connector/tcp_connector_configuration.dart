part of theater.remote;

/// Used to create and configure connection to other actor system.
class TcpConnectorConfiguration
    extends ConnectorConfiguration<TcpConnectorSecurityConfiguration> {
  /// Used to create and configure connection to other actor system.
  ///
  /// [name] - name of connection in actor system. Unique for each connection.
  ///
  /// [address] - address used to connect.
  ///
  /// [port] - port used to connect.
  ///
  /// [timeout] - timeout used when connected.
  ///
  /// [securityConfiguration] - used to configure security connection when connected.
  ///
  /// [reconnectTimeout] - time during which, in case of unsuccessful connection, there are repeated attempts to connect. By default equal 10 seconds.
  ///
  /// [reconnectDelay] - initial delay between reconnect attempts. By default equal 100 milliseconds.
  ///
  /// [supervisingStrategy] - .
  TcpConnectorConfiguration(
      {required String name,
      required dynamic address,
      required int port,
      Duration? timeout,
      TcpConnectorSecurityConfiguration? securityConfiguration,
      Duration? reconnectTimeout,
      double? reconnectDelay,
      ConnectorSupervisingStrategy? supervisingStrategy})
      : super(
            name,
            address,
            port,
            timeout,
            securityConfiguration,
            reconnectTimeout,
            reconnectDelay,
            supervisingStrategy ??
                ConnectorSupervisingStrategy(
                    desider: ConnectorDefaultDecider()));
}
