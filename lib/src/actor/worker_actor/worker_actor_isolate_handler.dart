part of theater.actor;

class WorkerActorIsolateHandler
    extends SheetActorIsolateHandler<WorkerActor, WorkerActorContext> {
  WorkerActorIsolateHandler(IsolateContext isolateContext, WorkerActor actor,
      WorkerActorContext actorContext)
      : super(isolateContext, actor, actorContext) {
    isolateContext.actions.listen(_handleAction);
  }
}
