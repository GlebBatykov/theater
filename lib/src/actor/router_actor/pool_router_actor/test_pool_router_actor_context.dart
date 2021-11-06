part of theater.actor;

class TestPoolRouterActorContext extends PoolRouterActorContext {
  TestPoolRouterActorContext(
      IsolateContext isolateContext, PoolRouterActorProperties actorProperties)
      : super(isolateContext, actorProperties);

  Future<void> initialize() async {
    await _initialize();
  }
}
