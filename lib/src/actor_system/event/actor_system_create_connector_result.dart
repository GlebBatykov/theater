part of theater.actor_system;

abstract class ActorSystemCreateConnectorResult extends ActorSystemEvent {}

class ActorSystemCreateConnectorSuccess
    extends ActorSystemCreateConnectorResult {
  final OutgoingConnection connection;

  ActorSystemCreateConnectorSuccess(this.connection);
}

class ActorSystemCreateConnectorNameExist
    extends ActorSystemCreateConnectorResult {}
