part of theater.actor;

abstract class ActorSystemAction {}

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

class ActorSystemGetLocalActorRef extends ActorSystemAction {
  final ActorPath actorPath;

  final SendPort feedbackPort;

  ActorSystemGetLocalActorRef(this.actorPath, this.feedbackPort);
}

class ActorSystemGetUserLocalActorRef extends ActorSystemGetLocalActorRef {
  ActorSystemGetUserLocalActorRef(ActorPath actorPath, SendPort feedbackPort)
      : super(actorPath, feedbackPort);
}

class ActorSystemGetSystemLocalActorRef extends ActorSystemGetLocalActorRef {
  ActorSystemGetSystemLocalActorRef(ActorPath actorPath, SendPort feedbackPort)
      : super(actorPath, feedbackPort);
}

abstract class ActorSystemIsExistLocalActorRef extends ActorSystemAction {
  final ActorPath actorPath;

  final SendPort feedbackPort;

  ActorSystemIsExistLocalActorRef(this.actorPath, this.feedbackPort);
}

class ActorSystemIsExistUserLocalActorRef
    extends ActorSystemIsExistLocalActorRef {
  ActorSystemIsExistUserLocalActorRef(
      ActorPath actorPath, SendPort feedbackPort)
      : super(actorPath, feedbackPort);
}

class ActorSystemIsExistSystemLocalActorRef
    extends ActorSystemIsExistLocalActorRef {
  ActorSystemIsExistSystemLocalActorRef(
      ActorPath actorPath, SendPort feedbackPort)
      : super(actorPath, feedbackPort);
}
