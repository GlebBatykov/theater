part of theater.actor;

class UntypedActorProperties extends NodeActorProperties {
  UntypedActorProperties(
      {required LocalActorRef actorRef,
      required SupervisorStrategy supervisorStrategy,
      required LocalActorRef parentRef,
      required MailboxType mailboxType,
      required SendPort actorSystemMessagePort,
      Map<String, dynamic>? data})
      : super(parentRef, supervisorStrategy, actorRef, mailboxType,
            actorSystemMessagePort, data ?? {});
}
