part of theater.actor_system;

abstract class ActorSystemRemoveLocalActorRef extends ActorSystemAction {
  final ActorPath path;

  ActorSystemRemoveLocalActorRef(this.path);
}

class ActorSystemRemoveUserLocalActorRef
    extends ActorSystemRemoveLocalActorRef {
  ActorSystemRemoveUserLocalActorRef(ActorPath path) : super(path);
}

class ActorSystemRemoveSystemLocalActorRef
    extends ActorSystemRemoveLocalActorRef {
  ActorSystemRemoveSystemLocalActorRef(ActorPath path) : super(path);
}
