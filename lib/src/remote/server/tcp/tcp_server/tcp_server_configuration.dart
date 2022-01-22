part of theater.remote;

class TcpServerConfiguration
    extends ServerConfiguration<TcpServerSecurityConfiguration> {
  TcpServerConfiguration(
      {required dynamic address,
      required int port,
      TcpServerSecurityConfiguration? securityConfiguration})
      : super(address, port, securityConfiguration);
}
