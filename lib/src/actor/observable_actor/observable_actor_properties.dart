part of theater.actor;

abstract class ObservableActorProperties extends ActorProperties {
  ObservableActorProperties(LocalActorRef actorRef, MailboxType mailboxType,
      Map<String, dynamic> data)
      : super(actorRef, mailboxType, data);
}
