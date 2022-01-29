part of theater.remote;

/// Class is a base class to actor message deserializer classes.
abstract class ActorMessageTransportDeserializer {
  const ActorMessageTransportDeserializer();

  /// Deserializes actor remote messages.
  ///
  /// Used on messages received from other actor systems.
  dynamic deserialize(String tag, String data);
}
