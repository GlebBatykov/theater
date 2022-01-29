part of theater.remote;

/// Class is a base class to actor message serializer classes.
abstract class ActorMessageTransportSerializer {
  const ActorMessageTransportSerializer();

  /// Serializes actor remote messages.
  ///
  /// Used before sending a message to other actor system.
  String serialize(String tag, dynamic data);
}
