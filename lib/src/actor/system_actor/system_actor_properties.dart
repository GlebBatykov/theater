part of theater.actor;

class SystemActorProperties extends NodeActorProperties {
  final SystemActor actor;

  SystemActorProperties(
      {required this.actor,
      required LocalActorRef actorRef,
      required SupervisorStrategy supervisorStrategy,
      required LocalActorRef parentRef,
      required MailboxType mailboxType,
      required SendPort actorSystemMessagePort,
      Map<String, dynamic>? data})
      : super(parentRef, supervisorStrategy, actorRef, mailboxType,
            actorSystemMessagePort, data ?? {});
}
