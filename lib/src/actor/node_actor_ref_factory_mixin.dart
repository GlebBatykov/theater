part of theater.actor;

mixin NodeActorRefFactoryMixin<P extends SupervisorActorProperties>
    on SupervisorActorContext<P> implements ActorRefFactory<NodeActor> {
  @override
  Future<LocalActorRef> actorOf<T extends NodeActor>(String name, T actor,
      {Map<String, dynamic>? data, void Function()? onKill}) async {
    var actorPath = path.createChild(name);

    if (_children.map((e) => e.path).contains(actorPath)) {
      throw ActorContextException(
          message: 'actor contains child actor with name [$name]');
    }
    _childErrorSubscription.pause();

    var actorCellFactory = actor._createActorCellFactory();

    var actorCell = actorCellFactory.create(
        actorPath,
        actor,
        NodeActorCellProperties(
            actorSystemSendPort: _actorProperties.actorSystemSendPort,
            parentRef: _actorProperties.actorRef,
            loggingProperties: ActorLoggingProperties.fromLoggingProperties(
                _actorProperties.loggingProperties,
                actor.createLoggingPropeties()),
            data: data,
            onKill: onKill));

    actorCell.errors.listen((error) => _childErrorController.sink.add(error));

    _children.add(actorCell);

    await actorCell.initialize();

    await actorCell.start();

    _childErrorSubscription.resume();

    return actorCell.ref;
  }
}
