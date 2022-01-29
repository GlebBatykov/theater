part of theater.remote;

class DefaultActorMessageTransportDeserializer
    extends ActorMessageTransportDeserializer {
  const DefaultActorMessageTransportDeserializer();

  @override
  dynamic deserialize(String tag, String data) {
    return data;
  }
}
