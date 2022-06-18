part of theater.actor_system;

abstract class ActorSystemGetRemoteUserActorsPathsResult
    extends ActorSystemEvent {}

class ActorSystemGetRemoteUserActorsPathsSuccess
    extends ActorSystemGetRemoteUserActorsPathsResult {
  final List<ActorPath> paths;

  ActorSystemGetRemoteUserActorsPathsSuccess(this.paths);
}

class ActorSystemGetRemoteUserActorsPathsConnectionNotExist
    extends ActorSystemGetRemoteUserActorsPathsResult {}
