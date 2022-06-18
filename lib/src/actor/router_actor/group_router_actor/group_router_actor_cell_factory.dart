part of theater.actor;

class GroupRouterActorCellFactory extends RouterActorCellFactory<
    GroupRouterActor, GroupRouterActorCell, NodeActorCellProperties> {
  @override
  GroupRouterActorCell create(ActorPath path, GroupRouterActor actor,
      NodeActorCellProperties properties) {
    return GroupRouterActorCell(path, actor, properties.parentRef,
        properties.actorSystemSendPort, properties.loggingProperties,
        data: properties.data,
        onError: properties.onError,
        onKill: properties.onKill);
  }
}
