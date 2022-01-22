part of theater.remote;

class TcpServerSecurityConfiguration extends TcpSecurityConfiguration {
  TcpServerSecurityConfiguration(
      {SecurityContext? securityContext, String? key, Duration? timeout})
      : super(securityContext, key, timeout);
}
