part of theater.system_actors;

abstract class ActorSystemServerCreateConnectorResult
    extends ActorSystemServerEvent {}

class ActorSystemServerCreateConnectorSuccess
    extends ActorSystemServerCreateConnectorResult {
  final ConnectorSource source;

  ActorSystemServerCreateConnectorSuccess(this.source);
}

class ActorSystemServerCreateConnectorNameExist
    extends ActorSystemServerCreateConnectorResult {}
