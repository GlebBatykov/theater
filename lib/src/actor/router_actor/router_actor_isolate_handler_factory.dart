part of theater.actor;

class RouterActorIsolateHandlerFactory extends NodeActorIsolateHandlerFactory<
    RouterActorIsolateHandler, RouterActor, RouterActorContext> {
  @override
  RouterActorIsolateHandler create(
      IsolateContext isolateContext,
      RouterActor actor,
      RouterActorContext<RouterActorProperties> actorContext) {
    return RouterActorIsolateHandler(isolateContext, actor, actorContext);
  }
}
