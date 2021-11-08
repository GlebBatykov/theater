part of theater.actor;

class RootActorProperties extends SupervisorActorProperties {
  RootActorProperties(
      {required LocalActorRef actorRef,
      required SupervisorStrategy supervisorStrategy,
      required MailboxType mailboxType,
      required SendPort actorSystemMessagePort,
      Map<String, dynamic>? data})
      : super(supervisorStrategy, actorRef, mailboxType, actorSystemMessagePort,
            data ?? {});
}
