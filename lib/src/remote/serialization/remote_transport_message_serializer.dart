part of theater.remote;

abstract class RemoteTransportMessageSerializer {
  static String serialize(TransportMessage message) {
    return jsonEncode(message.toJson());
  }
}
