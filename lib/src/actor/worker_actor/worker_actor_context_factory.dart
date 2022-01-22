part of theater.actor;

class WorkerActorContextBuilder extends SheetActorContextBuilder<
    WorkerActorContext, WorkerActorProperties> {
  @override
  Future<WorkerActorContext> build(IsolateContext isolateContext,
      WorkerActorProperties actorProperties) async {
    var context = WorkerActorContext(isolateContext, actorProperties);

    await context._initialize();

    return context;
  }
}
