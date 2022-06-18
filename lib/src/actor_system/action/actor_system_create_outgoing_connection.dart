part of theater.actor_system;

class ActorSystemCreateConnector extends ActorSystemAction {
  final ConnectorConfiguration configuration;

  final SendPort feedbackPort;

  ActorSystemCreateConnector(this.configuration, this.feedbackPort);
}
