part of theater.remote;

abstract class TcpSecurityConfiguration extends SecurityConfiguration {
  final SecurityContext? securityContext;

  final String? key;

  final Duration timeout;

  bool get haveKey => key != null;

  bool get haveContext => securityContext != null;

  TcpSecurityConfiguration(this.securityContext, this.key, Duration? timeout)
      : timeout = timeout ?? Duration(seconds: 10);
}
