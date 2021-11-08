part of theater.actor;

abstract class ObservableActorProperties extends ActorProperties {
  ObservableActorProperties(LocalActorRef actorRef, MailboxType mailboxType,
      SendPort actorSystemMessagePort, Map<String, dynamic> data)
      : super(actorRef, mailboxType, actorSystemMessagePort, data);
}
