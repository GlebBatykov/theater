part of theater.actor;

abstract class RouterActorProperties extends NodeActorProperties {
  RouterActorProperties(
      {required super.parentRef,
      required super.handlingType,
      required super.supervisorStrategy,
      required super.actorRef,
      required super.mailboxType,
      required super.actorSystemSendPort,
      required super.loggingProperties,
      required super.data});
}
