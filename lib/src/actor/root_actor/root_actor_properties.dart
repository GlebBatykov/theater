part of theater.actor;

class RootActorProperties extends SupervisorActorProperties {
  RootActorProperties(
      {required super.actorRef,
      required super.handlingType,
      required super.supervisorStrategy,
      required super.mailboxType,
      required super.actorSystemSendPort,
      required super.loggingProperties,
      Map<String, dynamic>? data})
      : super(data: data ?? {});
}
