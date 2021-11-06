part of theater.actor;

class RootActorContextFactory extends SupervisorActorContextFactory<
    RootActorContext, RootActorProperties> {
  @override
  RootActorContext create(
      IsolateContext isolateContext, RootActorProperties actorProperties) {
    return RootActorContext(isolateContext, actorProperties);
  }
}
