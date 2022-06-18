part of theater.actor;

class WorkerActorCellProperties extends SheetActorCellProperties {
  WorkerActorCellProperties(
      {required LocalActorRef parentRef,
      Map<String, dynamic>? data,
      required SendPort actorSystemSendPort,
      required LoggingProperties loggingProperties,
      void Function()? onKill,
      void Function(ActorError)? onError})
      : super(parentRef, data ?? {}, actorSystemSendPort, loggingProperties,
            onKill, onError);
}
