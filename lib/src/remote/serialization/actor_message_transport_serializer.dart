part of theater.remote;

abstract class ActorMessageTransportSerializer {
  const ActorMessageTransportSerializer();

  String serialize(String tag, dynamic data);
}

class DefaultActorMessageTransportSerializer
    extends ActorMessageTransportSerializer {
  const DefaultActorMessageTransportSerializer();

  @override
  String serialize(String tag, dynamic data) {
    return data.toString();
  }
}
