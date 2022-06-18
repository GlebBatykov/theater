part of theater.actor_system;

class ActorSystemCreateServer extends ActorSystemAction {
  final ServerConfiguration configuration;

  final SendPort feedbackPort;

  ActorSystemCreateServer(this.configuration, this.feedbackPort);
}
