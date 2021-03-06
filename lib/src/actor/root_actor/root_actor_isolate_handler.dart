part of theater.actor;

class RootActorIsolateHandler
    extends SupervisorActorIsolateHandler<RootActor, RootActorContext> {
  RootActorIsolateHandler(IsolateContext isolateContext, RootActor actor,
      RootActorContext actorContext)
      : super(isolateContext, actor, actorContext) {
    isolateContext.actions.listen(_handleAction);
  }
}
