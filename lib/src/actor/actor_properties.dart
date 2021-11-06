part of theater.actor;

abstract class ActorProperties {
  final ActorPath path;

  final MailboxType mailboxType;

  final LocalActorRef actorRef;

  final Map<String, dynamic> data;

  ActorProperties(LocalActorRef actorRef, this.mailboxType, this.data)
      : path = actorRef.path,
        actorRef = actorRef;
}
