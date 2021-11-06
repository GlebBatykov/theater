part of theater.actor;

abstract class SupervisorActorProperties extends ActorProperties {
  final SupervisorStrategy supervisorStrategy;

  SupervisorActorProperties(this.supervisorStrategy, LocalActorRef actorRef,
      MailboxType mailboxType, Map<String, dynamic> data)
      : super(actorRef, mailboxType, data);
}
