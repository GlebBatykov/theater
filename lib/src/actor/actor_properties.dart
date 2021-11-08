part of theater.actor;

abstract class ActorProperties {
  final ActorPath path;

  final MailboxType mailboxType;

  final LocalActorRef actorRef;

  final SendPort actorSystemMessagePort;

  final Map<String, dynamic> data;

  ActorProperties(LocalActorRef actorRef, this.mailboxType,
      this.actorSystemMessagePort, this.data)
      : path = actorRef.path,
        actorRef = actorRef;
}
