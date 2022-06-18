part of theater.actor_system;

class ActorSystemGetRemoteConnections extends ActorSystemAction {
  final SendPort feedbackPort;

  ActorSystemGetRemoteConnections(this.feedbackPort);
}
