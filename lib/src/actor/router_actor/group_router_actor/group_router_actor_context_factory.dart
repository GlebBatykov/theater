part of theater.actor;

class GroupRouterActorContextFactory extends RouterActorContextFactory<
    GroupRouterActorContext, GroupRouterActorProperties> {
  @override
  GroupRouterActorContext create(IsolateContext isolateContext,
      GroupRouterActorProperties actorProperties) {
    return GroupRouterActorContext(isolateContext, actorProperties);
  }
}
