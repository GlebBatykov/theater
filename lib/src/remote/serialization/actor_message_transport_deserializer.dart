part of theater.remote;

abstract class ActorMessageTransportDeserializer {
  const ActorMessageTransportDeserializer();

  dynamic deserialize(String tag, String data);
}
