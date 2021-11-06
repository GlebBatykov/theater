part of theater.actor;

class UntypedActorContextFactory extends NodeActorContextFactory<
    UntypedActorContext, UntypedActorProperties> {
  @override
  UntypedActorContext<UntypedActorProperties> create(
      IsolateContext isolateContext, UntypedActorProperties actorProperties) {
    return UntypedActorContext(isolateContext, actorProperties);
  }
}
