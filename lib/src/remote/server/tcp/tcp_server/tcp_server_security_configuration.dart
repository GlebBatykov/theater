part of theater.remote;

/// Used to configure security in tcp server of actor system.
class TcpServerSecurityConfiguration extends TcpSecurityConfiguration {
  /// Used to configure security in tcp server of actor system.
  ///
  /// [securityContext] used to configure security.
  ///
  /// [key] used to configure authorization by key.
  ///
  /// [timeout] is delay before the connection is terminated in case of an unsuccessful authorization attempt by key during this time.
  ///
  /// [timeout] by default equal 10 seconds.
  TcpServerSecurityConfiguration(
      {SecurityContext? securityContext, String? key, Duration? timeout})
      : super(securityContext, key, timeout);
}
