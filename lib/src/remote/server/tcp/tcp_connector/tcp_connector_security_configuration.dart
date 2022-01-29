part of theater.remote;

/// Used to configure security in tcp connection to other actor system.
class TcpConnectorSecurityConfiguration extends TcpSecurityConfiguration {
  final bool Function(X509Certificate)? onBadCertificate;

  /// Used to configure security in tcp connection to other actor system.
  ///
  /// [securityContext] used to configure security.
  ///
  /// [onBadCertificate] used to override certificate validation.
  ///
  /// [key] used to configure authorization by key.
  ///
  /// [timeout] is delay before the connection is terminated in case of an unsuccessful authorization attempt by key during this time.
  ///
  /// [timeout] by default equal 10 seconds.
  TcpConnectorSecurityConfiguration(
      {SecurityContext? securityContext,
      String? key,
      this.onBadCertificate,
      Duration? timeout})
      : super(securityContext, key, timeout);
}
