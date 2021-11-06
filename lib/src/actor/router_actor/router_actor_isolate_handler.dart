part of theater.actor;

class RouterActorIsolateHandler
    extends NodeActorIsolateHandler<RouterActor, RouterActorContext> {
  RouterActorIsolateHandler(IsolateContext isolateContext, RouterActor actor,
      RouterActorContext actorContext)
      : super(isolateContext, actor, actorContext) {
    isolateContext.actions.listen(_handleAction);
  }
}
