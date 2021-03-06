part of theater.actor;

class SystemActorCellFactory extends NodeActorCellFactory<SystemActor,
    SystemActorCell, NodeActorCellProperties> {
  @override
  SystemActorCell create(
      ActorPath path, SystemActor actor, NodeActorCellProperties properties) {
    return SystemActorCell(
        path, actor, properties.parentRef, properties.actorSystemMessagePort,
        data: properties.data,
        onError: properties.onError,
        onKill: properties.onKill);
  }
}
