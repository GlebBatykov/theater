part of theater.actor;

class PoolRouterActorCellFactory extends RouterActorCellFactory<PoolRouterActor,
    PoolRouterActorCell, NodeActorCellProperties> {
  @override
  PoolRouterActorCell create(ActorPath path, PoolRouterActor actor,
      NodeActorCellProperties properties) {
    return PoolRouterActorCell(path, actor, properties.parentRef,
        properties.actorSystemSendPort, properties.loggingProperties,
        data: properties.data,
        onError: properties.onError,
        onKill: properties.onKill);
  }
}
