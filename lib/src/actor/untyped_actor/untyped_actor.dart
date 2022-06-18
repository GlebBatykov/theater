part of theater.actor;

/// This class is a base class for actors who don't have initial special role (like [GroupRouterActor] or [PoolRouterActor] - they initial role are routing messages).
///
/// Most of the time you will use this actor for creating your actors.
abstract class UntypedActor extends NodeActor<UntypedActorContext> {
  @override
  UntypedActorCellFactory _createActorCellFactory() =>
      UntypedActorCellFactory();
}
