part of theater.actor;

class GroupRouterActorContextBuilder extends RouterActorContextBuilder<
    GroupRouterActorContext, GroupRouterActorProperties> {
  @override
  Future<GroupRouterActorContext> build(IsolateContext isolateContext,
      GroupRouterActorProperties actorProperties) async {
    var context = GroupRouterActorContext(isolateContext, actorProperties);

    await context._initialize();

    return context;
  }
}
