part of theater.actor;

abstract class ObservableActorCell<A extends ObservableActor>
    extends ActorCell<A> {
  ObservableActorCell(
      ActorPath path, A actor, Mailbox mailbox, void Function() onKill)
      : super(path, actor, mailbox, onKill);
}
