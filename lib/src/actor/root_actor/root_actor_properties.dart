part of theater.actor;

class RootActorProperties extends SupervisorActorProperties {
  RootActorProperties(
      {required LocalActorRef actorRef,
      required SupervisorStrategy supervisorStrategy,
      required MailboxType mailboxType,
      Map<String, dynamic>? data})
      : super(supervisorStrategy, actorRef, mailboxType, data ?? {});
}
