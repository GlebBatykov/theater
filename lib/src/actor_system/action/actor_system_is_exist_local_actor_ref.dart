part of theater.actor_system;

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
