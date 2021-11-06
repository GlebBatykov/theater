part of theater.actor;

abstract class SupervisorActorCell<A extends SupervisorActor>
    extends ActorCell<A> {
  SupervisorActorCell(
      ActorPath path, A actor, Mailbox mailbox, void Function()? onKill)
      : super(path, actor, mailbox, onKill);
}
