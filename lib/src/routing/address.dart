part of theater.routing;

/// Used in [ActorPath] for storing [ActorSystem] name, host address and protocol.
class Address {
  /// Name of [ActorSystem].
  final String system;

  /// Host internet address.
  final String? host;

  /// Port which the used [ActorSystem].
  final int? port;

  Address(this.system, {String? host, int? port})
      : host = host,
        port = port;

  @override
  String toString() {
    return system +
        (host != null ? '@' + host! : '') +
        (port != null ? ':' + port!.toString() : '');
  }
}
