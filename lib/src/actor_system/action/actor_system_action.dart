part of theater.actor_system;

abstract class ActorSystemAction {}

class ActorSystemAddTopicMessage extends ActorSystemAction {
  final ActorSystemTopicMessage message;

  ActorSystemAddTopicMessage(this.message);
}

class ActorSystemRouteActorRemoteMessage extends ActorSystemAction {
  final ActorRemoteMessage message;

  ActorSystemRouteActorRemoteMessage(this.message);
}

class ActorSystemSetRemoteSources extends ActorSystemAction {
  final List<RemoteSource> remoteSources;

  ActorSystemSetRemoteSources(this.remoteSources);
}

class ActorSystemCreateRemoteActorRef extends ActorSystemAction {
  final SendPort feedbackPort;

  final String connectionName;

  final ActorPath path;

  ActorSystemCreateRemoteActorRef(
      this.feedbackPort, this.connectionName, this.path);
}
