part of theater.actor;

class PoolRouterActorContextFactory extends RouterActorContextFactory<
    PoolRouterActorContext, PoolRouterActorProperties> {
  @override
  PoolRouterActorContext create(IsolateContext isolateContext,
      PoolRouterActorProperties actorProperties) {
    return PoolRouterActorContext(isolateContext, actorProperties);
  }
}
