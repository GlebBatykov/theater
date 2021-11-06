part of theater.actor;

class PoolRouterActorProperties extends RouterActorProperties {
  final PoolDeployementStrategy deployementStrategy;

  PoolRouterActorProperties(
      {required this.deployementStrategy,
      required LocalActorRef actorRef,
      required SupervisorStrategy supervisorStrategy,
      required LocalActorRef parentRef,
      required MailboxType mailboxType,
      Map<String, dynamic>? data})
      : super(parentRef, supervisorStrategy, actorRef, mailboxType, data ?? {});
}
