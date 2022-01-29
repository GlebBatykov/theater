part of theater.remote;

abstract class ActorMessageTransportSerializer {
  const ActorMessageTransportSerializer();

  String serialize(String tag, dynamic data);
}
