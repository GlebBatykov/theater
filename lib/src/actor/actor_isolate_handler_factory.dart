part of theater.actor;

abstract class ActorIsolateHandlerFactory<H extends ActorIsolateHandler,
    A extends Actor, C extends ActorContext> {
  H create(IsolateContext isolateContext, A actor, C actorContext);
}
