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
