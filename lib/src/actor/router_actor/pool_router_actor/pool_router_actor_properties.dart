part of theater.actor;

class PoolRouterActorProperties extends RouterActorProperties {
  final PoolDeployementStrategy deployementStrategy;

  PoolRouterActorProperties(
      {required this.deployementStrategy,
      required LocalActorRef actorRef,
      required SupervisorStrategy supervisorStrategy,
      required LocalActorRef parentRef,
      required MailboxType mailboxType,
      required SendPort actorSystemMessagePort,
      Map<String, dynamic>? data})
      : super(parentRef, supervisorStrategy, actorRef, mailboxType,
            actorSystemMessagePort, data ?? {});
}
