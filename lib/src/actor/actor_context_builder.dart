part of theater.actor;

abstract class ActorContextBuilder<C extends ActorContext,
    P extends ActorProperties> {
  Future<C> build(IsolateContext isolateContext, P actorProperties);
}
