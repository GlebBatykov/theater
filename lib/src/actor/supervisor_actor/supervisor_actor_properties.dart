part of theater.actor;

abstract class SupervisorActorProperties extends ActorProperties {
  final SupervisorStrategy supervisorStrategy;

  SupervisorActorProperties(
      {required this.supervisorStrategy,
      required super.handlingType,
      required super.actorRef,
      required super.mailboxType,
      required super.actorSystemSendPort,
      required super.loggingProperties,
      required super.data});
}
