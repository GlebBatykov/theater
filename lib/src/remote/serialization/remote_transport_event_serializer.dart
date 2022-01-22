part of theater.remote;

abstract class RemoteTransportEventSerializer {
  static String serialize(RemoteTransportEvent event) {
    return jsonEncode(event.toJson());
  }
}
