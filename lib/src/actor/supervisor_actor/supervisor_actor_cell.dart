part of theater.actor;

abstract class SupervisorActorCell<A extends SupervisorActor>
    extends ActorCell<A> {
  SupervisorActorCell(
      ActorPath path,
      A actor,
      Mailbox mailbox,
      SendPort actorSystemSendPort,
      LoggingProperties loggingProperties,
      void Function()? onKill)
      : super(path, actor, mailbox, actorSystemSendPort, loggingProperties,
            onKill);
}
