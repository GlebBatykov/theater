part of theater.actor;

class UntypedActorIsolateHandler
    extends NodeActorIsolateHandler<UntypedActor, UntypedActorContext> {
  UntypedActorIsolateHandler(IsolateContext isolateContext, UntypedActor actor,
      UntypedActorContext actorContext)
      : super(isolateContext, actor, actorContext) {
    isolateContext.actions.listen(_handleAction);
  }
}
