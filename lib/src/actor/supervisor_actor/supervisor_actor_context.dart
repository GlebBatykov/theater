part of theater.actor;

abstract class SupervisorActorContext<P extends SupervisorActorProperties>
    extends ActorContext<P> with ActorParent<P> {
  SupervisorActorContext(IsolateContext isolateContext, P actorProperties)
      : super(isolateContext, actorProperties);
}
