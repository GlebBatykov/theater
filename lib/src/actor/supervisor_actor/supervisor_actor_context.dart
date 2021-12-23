part of theater.actor;

abstract class SupervisorActorContext<P extends SupervisorActorProperties>
    extends ActorContext<P> with ActorParentMixin<P> {
  SupervisorActorContext(IsolateContext isolateContext, P actorProperties)
      : super(isolateContext, actorProperties);
}
