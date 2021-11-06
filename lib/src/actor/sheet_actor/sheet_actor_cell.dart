part of theater.actor;

abstract class SheetActorCell<A extends SheetActor> extends ActorCell<A> {
  final LocalActorRef _parentRef;

  SheetActorCell(ActorPath path, A actor, LocalActorRef parentRef,
      Mailbox mailbox, void Function()? onKill)
      : _parentRef = parentRef,
        super(path, actor, mailbox, onKill);
}
