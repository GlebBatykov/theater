part of theater.actor;

class SystemActorContextBuilder
    extends NodeActorContextBuilder<SystemActorContext, SystemActorProperties> {
  @override
  Future<SystemActorContext> build(IsolateContext isolateContext,
      SystemActorProperties actorProperties) async {
    return SystemActorContext(isolateContext, actorProperties);
  }
}
