part of theater.actor_system;

abstract class ActorSystemGetRemoteConnectionResult {}

class ActorSystemGetRemoteConnectionSuccess
    extends ActorSystemGetRemoteConnectionResult {
  final OutgoingConnection connection;

  ActorSystemGetRemoteConnectionSuccess(this.connection);
}

class ActorSystemGetRemoteConnectionNotExist
    extends ActorSystemGetRemoteConnectionResult {}
