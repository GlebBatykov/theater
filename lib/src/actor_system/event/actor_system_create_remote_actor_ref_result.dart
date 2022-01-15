part of theater.actor_system;

abstract class ActorSystemCreateRemoteActorRefResult extends ActorSystemEvent {}

class ActorSystemCreateRemoteActorRefSuccess
    extends ActorSystemCreateRemoteActorRefResult {
  final RemoteActorRef ref;

  ActorSystemCreateRemoteActorRefSuccess(this.ref);
}

class ActorSystemCreateRemoteActorRefConnectionNotExist
    extends ActorSystemCreateRemoteActorRefResult {}
