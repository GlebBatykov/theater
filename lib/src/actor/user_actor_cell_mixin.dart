part of theater.actor;

mixin UserActorCellMixin<A extends Actor> on ActorCell<A> {
  @override
  Future<void> initialize() async {
    await super.initialize();

    _actorSystemSendPort.send(ActorSystemRegisterUserLocalActorRef(ref));
  }

  @override
  Future<void> dispose() async {
    await super.dispose();

    _actorSystemSendPort.send(ActorSystemRemoveUserLocalActorRef(path));
  }
}
