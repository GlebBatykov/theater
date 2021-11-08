part of theater.actor;

class WorkerActorCellProperties extends SheetActorCellProperties {
  WorkerActorCellProperties(
      {required LocalActorRef parentRef,
      Map<String, dynamic>? data,
      required SendPort actorSystemMessagePort,
      void Function()? onKill,
      void Function(ActorError)? onError})
      : super(parentRef, data ?? {}, actorSystemMessagePort, onKill, onError);
}
