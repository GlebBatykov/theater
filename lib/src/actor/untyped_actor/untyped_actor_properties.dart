part of theater.actor;

class UntypedActorProperties extends NodeActorProperties {
  UntypedActorProperties(
      {required super.actorRef,
      required super.supervisorStrategy,
      required super.parentRef,
      required super.handlingType,
      required super.mailboxType,
      required super.actorSystemSendPort,
      required super.loggingProperties,
      Map<String, dynamic>? data})
      : super(data: data ?? {});
}
