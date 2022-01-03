part of theater.actor;

mixin UserActorCellMixin<A extends Actor> on ActorCell<A> {
  @override
  Future<void> initialize() async {
    await super.initialize();

    _actorSystemMessagePort.send(ActorSystemRegisterUserLocalActorRef(ref));
  }

  @override
  Future<void> dispose() async {
    await super.dispose();

    _actorSystemMessagePort.send(ActorSystemRemoveUserLocalActorRef(path));
  }
}
