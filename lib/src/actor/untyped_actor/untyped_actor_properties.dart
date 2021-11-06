part of theater.actor;

class UntypedActorProperties extends NodeActorProperties {
  UntypedActorProperties(
      {required LocalActorRef actorRef,
      required SupervisorStrategy supervisorStrategy,
      required LocalActorRef parentRef,
      required MailboxType mailboxType,
      Map<String, dynamic>? data})
      : super(parentRef, supervisorStrategy, actorRef, mailboxType, data ?? {});
}
