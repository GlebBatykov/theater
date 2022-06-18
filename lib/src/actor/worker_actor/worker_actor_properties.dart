part of theater.actor;

class WorkerActorProperties extends SheetActorProperties {
  WorkerActorProperties(
      {required super.actorRef,
      required super.handlingType,
      required super.parentRef,
      required super.mailboxType,
      required super.actorSystemSendPort,
      required super.loggingProperties,
      Map<String, dynamic>? data})
      : super(data: data ?? {});
}
