part of theater.actor;

/// This class is a base class for actors who are located in pool in [PoolRouterActor].
class WorkerActor extends SheetActor<WorkerActorContext> {
  @override
  WorkerActorCellFactory _createActorCellFactory() => WorkerActorCellFactory();
}
