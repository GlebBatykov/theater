part of theater.actor;

class UntypedActorCellFactory extends NodeActorCellFactory<UntypedActor,
    UntypedActorCell, NodeActorCellProperties> {
  @override
  UntypedActorCell create(
      ActorPath path, UntypedActor actor, NodeActorCellProperties properties) {
    return UntypedActorCell(path, actor, properties.parentRef,
        data: properties.data,
        onError: properties.onError,
        onKill: properties.onKill);
  }
}
