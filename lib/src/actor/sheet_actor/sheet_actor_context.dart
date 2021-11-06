part of theater.actor;

/// Class is a base class for all actor context classes owned by [SheetActor]-s.
abstract class SheetActorContext<P extends SheetActorProperties>
    extends ObservableActorContext<P> {
  SheetActorContext(IsolateContext isolateContext, P actorProperties)
      : super(isolateContext, actorProperties);
}
