part of theater.actor;

class SystemActorIsolateHandler
    extends NodeActorIsolateHandler<SystemActor, SystemActorContext> {
  SystemActorIsolateHandler(IsolateContext isolateContext, SystemActor actor,
      SystemActorContext actorContext)
      : super(isolateContext, actor, actorContext) {
    isolateContext.actions.listen(_handleAction);
  }
}
