part of theater.actor_system;

abstract class ActorSystemRegisterLocalActorRef extends ActorSystemAction {
  final LocalActorRef ref;

  ActorSystemRegisterLocalActorRef(this.ref);
}

class ActorSystemRegisterUserLocalActorRef
    extends ActorSystemRegisterLocalActorRef {
  ActorSystemRegisterUserLocalActorRef(LocalActorRef ref) : super(ref);
}

class ActorSystemRegisterSystemLocalActorRef
    extends ActorSystemRegisterLocalActorRef {
  ActorSystemRegisterSystemLocalActorRef(LocalActorRef ref) : super(ref);
}
