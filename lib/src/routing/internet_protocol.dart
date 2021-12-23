part of theater.routing;

class InternetProtocol {
  final String value;

  const InternetProtocol._(this.value);

  static const InternetProtocol tcp = InternetProtocol._('theater.tcp');

  static const InternetProtocol udp = InternetProtocol._('theater.udp');

  @override
  String toString() {
    return value;
  }
}
