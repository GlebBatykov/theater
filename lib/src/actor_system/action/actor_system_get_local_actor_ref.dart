part of theater.actor_system;

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
