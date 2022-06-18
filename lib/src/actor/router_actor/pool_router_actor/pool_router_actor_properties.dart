part of theater.actor;

class PoolRouterActorProperties extends RouterActorProperties {
  final PoolDeployementStrategy deployementStrategy;

  PoolRouterActorProperties(
      {required this.deployementStrategy,
      required super.actorRef,
      required super.supervisorStrategy,
      required super.parentRef,
      required super.handlingType,
      required super.mailboxType,
      required super.actorSystemSendPort,
      required super.loggingProperties,
      Map<String, dynamic>? data})
      : super(data: data ?? {});
}
