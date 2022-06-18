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
  final List<ConnectorSource> remoteSources;

  ActorSystemSetRemoteSources(this.remoteSources);
}

class ActorSystemCreateRemoteActorRef extends ActorSystemAction {
  final SendPort feedbackPort;

  final String connectionName;

  final ActorPath path;

  ActorSystemCreateRemoteActorRef(
      this.feedbackPort, this.connectionName, this.path);
}

class ActorSystemGetUserActorsPaths extends ActorSystemAction {
  final SendPort feedbackPort;

  ActorSystemGetUserActorsPaths(this.feedbackPort);
}

class ActorSystemGetRemoteUserActorsPaths extends ActorSystemAction {
  final SendPort feedbackPort;

  final String connectionName;

  ActorSystemGetRemoteUserActorsPaths(this.feedbackPort, this.connectionName);
}

class ActorSystemIsRemoteConnectionExist extends ActorSystemAction {
  final SendPort feedbackPort;

  final String connectionName;

  ActorSystemIsRemoteConnectionExist(this.feedbackPort, this.connectionName);
}
