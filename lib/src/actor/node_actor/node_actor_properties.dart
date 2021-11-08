part of theater.actor;

abstract class NodeActorProperties extends SupervisorActorProperties {
  final LocalActorRef parentRef;

  NodeActorProperties(
      this.parentRef,
      SupervisorStrategy supervisorStrategy,
      LocalActorRef actorRef,
      MailboxType mailboxType,
      SendPort actorSystemMessagePort,
      Map<String, dynamic> data)
      : super(supervisorStrategy, actorRef, mailboxType, actorSystemMessagePort,
            data);
}
