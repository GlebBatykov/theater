part of theater.actor;

class RootActorContextBuilder extends SupervisorActorContextBuilder<
    RootActorContext, RootActorProperties> {
  @override
  Future<RootActorContext> build(IsolateContext isolateContext,
      RootActorProperties actorProperties) async {
    var context = RootActorContext(isolateContext, actorProperties);

    await context._initialize();

    return context;
  }
}
