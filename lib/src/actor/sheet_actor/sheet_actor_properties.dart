part of theater.actor;

abstract class SheetActorProperties extends ObservableActorProperties {
  final LocalActorRef parentRef;

  SheetActorProperties(
      this.parentRef,
      LocalActorRef actorRef,
      MailboxType mailboxType,
      SendPort actorSystemMessagePort,
      Map<String, dynamic> data)
      : super(actorRef, mailboxType, actorSystemMessagePort, data);
}
