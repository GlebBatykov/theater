part of theater.actor;

abstract class ActorContextFactory<C extends ActorContext,
    P extends ActorProperties> {
  C create(IsolateContext isolateContext, P actorProperties);
}
