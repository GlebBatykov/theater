part of theater.actor;

abstract class RouterActorCell<A extends RouterActor> extends NodeActorCell<A> {
  RouterActorCell(ActorPath path, A actor, LocalActorRef parentRef,
      Mailbox mailbox, SendPort actorSystemMessagePort, void Function()? onKill)
      : super(path, actor, parentRef, mailbox, actorSystemMessagePort, onKill);
}
