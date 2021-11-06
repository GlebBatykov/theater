part of theater.actor;

/// Class is a base class for all actor context classes owned by [NodeActor]-s.
abstract class NodeActorContext<P extends NodeActorProperties>
    extends SupervisorActorContext<P> {
  NodeActorContext(IsolateContext isolateContext, P actorProperties)
      : super(isolateContext, actorProperties);
}
