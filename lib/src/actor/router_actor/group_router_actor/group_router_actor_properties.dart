part of theater.actor;

class GroupRouterActorProperties extends RouterActorProperties {
  final GroupDeployementStrategy deployementStrategy;

  GroupRouterActorProperties(
      {required this.deployementStrategy,
      required LocalActorRef actorRef,
      required SupervisorStrategy supervisorStrategy,
      required LocalActorRef parentRef,
      required MailboxType mailboxType,
      Map<String, dynamic>? data})
      : super(parentRef, supervisorStrategy, actorRef, mailboxType, data ?? {});
}
