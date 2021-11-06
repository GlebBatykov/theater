part of theater.actor;

abstract class RouterActorProperties extends NodeActorProperties {
  RouterActorProperties(
      LocalActorRef parentRef,
      SupervisorStrategy supervisorStrategy,
      LocalActorRef actorRef,
      MailboxType mailboxType,
      Map<String, dynamic> data)
      : super(parentRef, supervisorStrategy, actorRef, mailboxType, data);
}
