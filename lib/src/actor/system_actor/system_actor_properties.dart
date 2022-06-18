part of theater.actor;

class SystemActorProperties extends NodeActorProperties {
  final SystemActor actor;

  SystemActorProperties(
      {required this.actor,
      required super.actorRef,
      required super.handlingType,
      required super.supervisorStrategy,
      required super.parentRef,
      required super.mailboxType,
      required super.actorSystemSendPort,
      required super.loggingProperties,
      Map<String, dynamic>? data})
      : super(data: data ?? {});
}
