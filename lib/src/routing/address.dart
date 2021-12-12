part of theater.routing;

/// Used in [ActorPath] for storing [ActorSystem] name, host address and protocol.
class Address {
  /// Internet protocol used [ActorSystem] to communication with other [ActorSystem] (on others Dart VM).
  ///
  /// There are 2 protocol used:
  ///
  /// - tcp (by default);
  /// - udp.
  final InternetProtocol protocol;

  /// Name of [ActorSystem].
  final String system;

  /// Host internet address.
  final String? host;

  /// Port which the used [ActorSystem].
  final int? port;

  Address(this.system,
      {this.protocol = InternetProtocol.tcp, String? host, int? port})
      : host = host,
        port = port;

  @override
  String toString() {
    return protocol.toString() +
        '://' +
        system +
        (host != null ? '@' + host! : '') +
        (port != null ? ':' + port!.toString() : '');
  }
}
