part of theater.actor;

abstract class ActorSystemEvent {}

class ActorSystemGetLocalActorRefResult {
  final LocalActorRef? ref;

  ActorSystemGetLocalActorRefResult(this.ref);
}

class ActorSystemIsExistLocalActorRefResult {
  final bool isExist;

  ActorSystemIsExistLocalActorRefResult(this.isExist);
}
