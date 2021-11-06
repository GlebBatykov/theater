part of theater.actor;

class TestGroupRouterActorContext extends GroupRouterActorContext {
  TestGroupRouterActorContext(
      IsolateContext isolateContext, GroupRouterActorProperties actorProperties)
      : super(isolateContext, actorProperties);

  Future<void> initialize() async {
    await _initialize();
  }
}
