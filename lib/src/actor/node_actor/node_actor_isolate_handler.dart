part of theater.actor;

abstract class NodeActorIsolateHandler<A extends NodeActor,
    C extends NodeActorContext> extends SupervisorActorIsolateHandler<A, C> {
  NodeActorIsolateHandler(
      IsolateContext isolateContext, A actor, C actorContext)
      : super(isolateContext, actor, actorContext);
}
