part of theater.actor;

class UntypedActorContextBuilder extends NodeActorContextBuilder<
    UntypedActorContext, UntypedActorProperties> {
  @override
  Future<UntypedActorContext> build(IsolateContext isolateContext,
      UntypedActorProperties actorProperties) async {
    var context = UntypedActorContext(isolateContext, actorProperties);

    await context._initialize();

    return context;
  }
}
