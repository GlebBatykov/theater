part of theater.actor;

abstract class SystemActor extends NodeActor<SystemActorContext> {
  Future<void> handleRoutingSystemMessage(
      SystemActorContext context, SystemRoutingMessage message) async {}

  @override
  SystemActorCellFactory _createActorCellFactory() => SystemActorCellFactory();
}
