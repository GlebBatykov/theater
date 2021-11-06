part of theater.routing;

/// Used in [ActorPath] for storing [ActorSystem] name, host address and protocol.
class Address {
  /// Internet protocol used [ActorSystem] to communication with other [ActorSystem] (on others Dart VM).
  ///
  /// There are 2 protocol used:
  ///
  /// - tcp (by default);
  /// - udp.
  final String protocol;

  /// Name of [ActorSystem].
  final String system;

  /// Host internet address.
  final String? host;

  /// Port which the used [ActorSystem].
  final int? port;

  static const String defaultProtocol = 'tcp';

  Address(this.system,
      {this.protocol = defaultProtocol, String? host, int? port})
      : host = host,
        port = port;

  @override
  String toString() {
    return protocol +
        '://' +
        system +
        (host != null ? '@' + host! : '') +
        (port != null ? ':' + port!.toString() : '');
  }
}
