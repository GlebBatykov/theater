part of theater.actor;

class WorkerActorContextFactory extends SheetActorContextFactory<
    WorkerActorContext, WorkerActorProperties> {
  @override
  WorkerActorContext create(
      IsolateContext isolateContext, WorkerActorProperties actorProperties) {
    return WorkerActorContext(isolateContext, actorProperties);
  }
}
