part of theater.actor;

class UntypedActorIsolateHandlerFactory extends NodeActorIsolateHandlerFactory<
    UntypedActorIsolateHandler, UntypedActor, UntypedActorContext> {
  @override
  UntypedActorIsolateHandler create(IsolateContext isolateContext,
      UntypedActor actor, UntypedActorContext actorContext) {
    return UntypedActorIsolateHandler(isolateContext, actor, actorContext);
  }
}
