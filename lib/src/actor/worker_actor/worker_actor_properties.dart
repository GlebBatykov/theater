part of theater.actor;

class WorkerActorProperties extends SheetActorProperties {
  WorkerActorProperties(
      {required LocalActorRef actorRef,
      required LocalActorRef parentRef,
      required MailboxType mailboxType,
      Map<String, dynamic>? data})
      : super(parentRef, actorRef, mailboxType, data ?? {});
}
