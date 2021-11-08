part of theater.actor;

abstract class SupervisorActorProperties extends ActorProperties {
  final SupervisorStrategy supervisorStrategy;

  SupervisorActorProperties(
      this.supervisorStrategy,
      LocalActorRef actorRef,
      MailboxType mailboxType,
      SendPort actorSystemMessagePort,
      Map<String, dynamic> data)
      : super(actorRef, mailboxType, actorSystemMessagePort, data);
}
