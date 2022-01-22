part of theater.remote;

abstract class ActorMessageTransportDeserializer {
  const ActorMessageTransportDeserializer();

  dynamic deserialize(String tag, String data);
}

class DefaultActorMessageTransportDeserializer
    extends ActorMessageTransportDeserializer {
  const DefaultActorMessageTransportDeserializer();

  @override
  dynamic deserialize(String tag, String data) {
    return data;
  }
}
