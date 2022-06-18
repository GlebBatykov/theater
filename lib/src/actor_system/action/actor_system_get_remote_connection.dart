part of theater.actor_system;

class ActorSystemGetRemoteConnection extends ActorSystemAction {
  final SendPort feedbackPort;

  final String connectionName;

  ActorSystemGetRemoteConnection(this.feedbackPort, this.connectionName);
}
