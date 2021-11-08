part of theater.actor;

class WorkerActorProperties extends SheetActorProperties {
  WorkerActorProperties(
      {required LocalActorRef actorRef,
      required LocalActorRef parentRef,
      required MailboxType mailboxType,
      required SendPort actorSystemMessagePort,
      Map<String, dynamic>? data})
      : super(parentRef, actorRef, mailboxType, actorSystemMessagePort,
            data ?? {});
}
