part of theater.actor;

abstract class ObservableActorContext<P extends ObservableActorProperties>
    extends ActorContext<P> {
  ObservableActorContext(IsolateContext isolateContext, P actorProperties)
      : super(isolateContext, actorProperties);
}
