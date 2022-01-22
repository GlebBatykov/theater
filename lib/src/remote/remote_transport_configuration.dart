part of theater.remote;

///
class RemoteTransportConfiguration {
  ///
  final bool isRemoteTransportEnabled;

  ///
  final List<ServerConfiguration> servers;

  ///
  final List<ConnectorConfiguration> connectors;

  ///
  final ActorMessageTransportDeserializer deserializer;

  ///
  final ActorMessageTransportSerializer serializer;

  ///
  const RemoteTransportConfiguration(
      {this.isRemoteTransportEnabled = true,
      List<ServerConfiguration>? servers,
      List<ConnectorConfiguration>? connectors,
      this.serializer = const DefaultActorMessageTransportSerializer(),
      this.deserializer = const DefaultActorMessageTransportDeserializer()})
      : servers = servers ?? const [],
        connectors = connectors ?? const [];
}
