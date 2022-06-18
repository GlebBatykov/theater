part of theater.actor;

class WorkerActorCellFactory extends SheetActorCellFactory<WorkerActor,
    WorkerActorCell, WorkerActorCellProperties> {
  @override
  WorkerActorCell create(
      ActorPath path, WorkerActor actor, WorkerActorCellProperties properties) {
    return WorkerActorCell(path, actor, properties.parentRef,
        properties.actorSystemSendPort, properties.loggingProperties,
        data: properties.data,
        onError: properties.onError,
        onKill: properties.onKill);
  }
}
