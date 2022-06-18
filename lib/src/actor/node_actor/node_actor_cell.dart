part of theater.actor;

abstract class NodeActorCell<A extends NodeActor>
    extends SupervisorActorCell<A> {
  final LocalActorRef _parentRef;

  NodeActorCell(
      ActorPath path,
      A actor,
      LocalActorRef parentRef,
      Mailbox mailbox,
      SendPort actorSystemSendPort,
      LoggingProperties loggingProperties,
      void Function()? onKill)
      : _parentRef = parentRef,
        super(path, actor, mailbox, actorSystemSendPort, loggingProperties,
            onKill);
}
