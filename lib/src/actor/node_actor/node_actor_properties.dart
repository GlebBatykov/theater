part of theater.actor;

abstract class NodeActorProperties extends SupervisorActorProperties {
  final LocalActorRef parentRef;

  NodeActorProperties(
      {required this.parentRef,
      required super.handlingType,
      required super.supervisorStrategy,
      required super.actorRef,
      required super.mailboxType,
      required super.actorSystemSendPort,
      required super.loggingProperties,
      required super.data});
}
