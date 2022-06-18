part of theater.remote;

/// Used to create and configure server in the actor system.
class TcpServerConfiguration
    extends ServerConfiguration<TcpServerSecurityConfiguration> {
  /// Used to create and configure a server in the actor system.
  ///
  /// [name] - name which is used to deploy the server.
  ///
  /// [adress] - address which is used to deploy the server.
  ///
  /// [port] - port which is used to deploy the server.
  ///
  /// [securityConfiguration] - used to configure security in server.
  TcpServerConfiguration(
      {required String name,
      required int port,
      TcpServerSecurityConfiguration? securityConfiguration})
      : super(name, port, securityConfiguration);
}
