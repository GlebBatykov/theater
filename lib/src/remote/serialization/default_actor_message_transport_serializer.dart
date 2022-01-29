part of theater.remote;

class DefaultActorMessageTransportSerializer
    extends ActorMessageTransportSerializer {
  const DefaultActorMessageTransportSerializer();

  @override
  String serialize(String tag, dynamic data) {
    return data.toString();
  }
}
