part of theater.actor;

class WorkerActorIsolateHandlerFactory extends SheetActorIsolateHandlerFactory<
    WorkerActorIsolateHandler, WorkerActor, WorkerActorContext> {
  @override
  WorkerActorIsolateHandler create(IsolateContext isolateContext,
      WorkerActor actor, WorkerActorContext actorContext) {
    return WorkerActorIsolateHandler(isolateContext, actor, actorContext);
  }
}
