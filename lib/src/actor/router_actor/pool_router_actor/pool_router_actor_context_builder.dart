part of theater.actor;

class PoolRouterActorContextBuilder extends RouterActorContextBuilder<
    PoolRouterActorContext, PoolRouterActorProperties> {
  @override
  Future<PoolRouterActorContext> build(IsolateContext isolateContext,
      PoolRouterActorProperties actorProperties) async {
    var context = PoolRouterActorContext(isolateContext, actorProperties);

    await context._initialize();

    return context;
  }
}
