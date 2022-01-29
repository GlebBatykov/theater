part of theater.remote;

abstract class RemoteTransportMessageDeserializer {
  static TransportMessage deserialize(Uint8List bytes) {
    var data = utf8.decode(bytes);

    var json = jsonDecode(data);

    return TransportMessage.fromJson(json);
  }
}
