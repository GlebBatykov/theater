part of theater.actor_system;

abstract class ActorSystemEvent {}

class ActorSystemGetLocalActorRefResult extends ActorSystemEvent {
  final LocalActorRef? ref;

  ActorSystemGetLocalActorRefResult(this.ref);
}

class ActorSystemIsExistLocalActorRefResult extends ActorSystemEvent {
  final bool isExist;

  ActorSystemIsExistLocalActorRefResult(this.isExist);
}

class ActorSystemGetUserActorsPathsResult extends ActorSystemEvent {
  final List<ActorPath> paths;

  ActorSystemGetUserActorsPathsResult(this.paths);
}

class ActorSystemGetRemoteConnectionsResult extends ActorSystemEvent {
  final List<OutgoingConnection> connections;

  ActorSystemGetRemoteConnectionsResult(this.connections);
}
