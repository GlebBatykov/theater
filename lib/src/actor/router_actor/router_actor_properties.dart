part of theater.actor;

abstract class RouterActorProperties extends NodeActorProperties {
  RouterActorProperties(
      LocalActorRef parentRef,
      SupervisorStrategy supervisorStrategy,
      LocalActorRef actorRef,
      MailboxType mailboxType,
      SendPort actorSystemMessagePort,
      Map<String, dynamic> data)
      : super(parentRef, supervisorStrategy, actorRef, mailboxType,
            actorSystemMessagePort, data);
}
