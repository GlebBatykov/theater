part of theater.remote;

/// Used to create and configure server in the actor system.
class TcpServerConfiguration
    extends ServerConfiguration<TcpServerSecurityConfiguration> {
  /// Used to create and configure a server in the actor system.
  ///
  /// [adress] - address which is used to deploy the server.
  ///
  /// [port] - port which is used to deploy the server.
  ///
  /// [securityConfiguration] - used to configure security in server.
  TcpServerConfiguration(
      {required dynamic address,
      required int port,
      TcpServerSecurityConfiguration? securityConfiguration})
      : super(address, port, securityConfiguration);
}
