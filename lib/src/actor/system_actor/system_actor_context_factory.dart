part of theater.actor;

class SystemActorContextFactory
    extends NodeActorContextFactory<SystemActorContext, SystemActorProperties> {
  @override
  SystemActorContext create(
      IsolateContext isolateContext, SystemActorProperties actorProperties) {
    return SystemActorContext(isolateContext, actorProperties);
  }
}
