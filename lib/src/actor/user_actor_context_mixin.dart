part of theater.actor;

mixin UserActorContextMixin<P extends ActorProperties> on ActorContext<P> {
  @override
  Future<void> _initialize() async {
    _actorProperties.actorSystemMessagePort
        .send(ActorSystemRegisterUserLocalActorRef(_actorProperties.actorRef));
  }
}
