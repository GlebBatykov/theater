part of theater.remote;

class TcpConnectorSecurityConfiguration extends TcpSecurityConfiguration {
  final bool Function(X509Certificate)? onBadCertificate;

  TcpConnectorSecurityConfiguration(
      {SecurityContext? securityContext,
      String? key,
      this.onBadCertificate,
      Duration? timeout})
      : super(securityContext, key, timeout);
}
