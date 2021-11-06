part of theater.actor;

class WorkerActorCellProperties extends SheetActorCellProperties {
  WorkerActorCellProperties(
      {required LocalActorRef parentRef,
      Map<String, dynamic>? data,
      void Function()? onKill,
      void Function(ActorError)? onError})
      : super(parentRef, data ?? {}, onKill, onError);
}
