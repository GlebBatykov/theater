part of theater.actor;

abstract class SystemActor extends NodeActor<SystemActorContext> {
  Future<void> handleSystemMessage(
      SystemActorContext context, SystemMessage message) async {}

  @override
  SystemActorCellFactory _createActorCellFactory() => SystemActorCellFactory();
}
