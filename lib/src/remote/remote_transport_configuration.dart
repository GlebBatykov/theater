part of theater.remote;

/// Used to configure remoting in actor system.
class RemoteTransportConfiguration {
  /// Defines is active remoting in actor system.
  final bool isRemoteTransportEnabled;

  /// Used for deployment servers in actor system.
  final List<ServerConfiguration> servers;

  /// Used for create connection to other actor system.
  final List<ConnectorConfiguration> connectors;

  /// Used for deserialize remote messages.
  final ActorMessageTransportDeserializer deserializer;

  /// Used for serialize remote messages.
  final ActorMessageTransportSerializer serializer;

  /// Used to configure remoting in actor system.
  ///
  /// [isRemoteTransportEnabled] defines is active remoting in actor system, by default is true.
  ///
  /// If you don't specify your serializer, the default serializer will be used. It will return the original received string.
  ///
  /// If you don't specify your deserialize, the default deserialize will be used. It will try to cast the type of message being sent to a string.
  const RemoteTransportConfiguration(
      {this.isRemoteTransportEnabled = true,
      List<ServerConfiguration>? servers,
      List<ConnectorConfiguration>? connectors,
      this.serializer = const DefaultActorMessageTransportSerializer(),
      this.deserializer = const DefaultActorMessageTransportDeserializer()})
      : servers = servers ?? const [],
        connectors = connectors ?? const [];
}
