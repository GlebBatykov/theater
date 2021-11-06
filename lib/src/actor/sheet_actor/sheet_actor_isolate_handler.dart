part of theater.actor;

abstract class SheetActorIsolateHandler<A extends SheetActor,
    C extends SheetActorContext> extends ObservableActorIsolateHandler<A, C> {
  SheetActorIsolateHandler(
      IsolateContext isolateContext, A actor, C actorContext)
      : super(isolateContext, actor, actorContext);
}
