part of theater.actor;

abstract class NodeActorProperties extends SupervisorActorProperties {
  final LocalActorRef parentRef;

  NodeActorProperties(
      this.parentRef,
      SupervisorStrategy supervisorStrategy,
      LocalActorRef actorRef,
      MailboxType mailboxType,
      Map<String, dynamic> data)
      : super(supervisorStrategy, actorRef, mailboxType, data);
}
