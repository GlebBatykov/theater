part of theater.actor;

class SystemActorIsolateHandlerFactory extends NodeActorIsolateHandlerFactory<
    SystemActorIsolateHandler, SystemActor, SystemActorContext> {
  @override
  SystemActorIsolateHandler create(IsolateContext isolateContext,
      SystemActor actor, SystemActorContext actorContext) {
    return SystemActorIsolateHandler(isolateContext, actor, actorContext);
  }
}
