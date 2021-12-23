part of theater.actor;

class RootActorIsolateHandlerFactory
    extends SupervisorActorIsolateHandlerFactory<RootActorIsolateHandler,
        RootActor, RootActorContext> {
  @override
  RootActorIsolateHandler create(IsolateContext isolateContext, RootActor actor,
      RootActorContext actorContext) {
    return RootActorIsolateHandler(isolateContext, actor, actorContext);
  }
}
