part of theater.actor;

/// This class is a base class for actor routers who create pool of actor during initialization.
///
/// Pool of actors consists of the same type [WorkerActor].
abstract class PoolRouterActor extends RouterActor {
  /// Creates instanse of [PoolDeployementStrategy] which the used for initialize [PoolRouterActor].
  @override
  PoolDeployementStrategy createDeployementStrategy();

  @override
  PoolRouterActorCellFactory _createActorCellFactory() =>
      PoolRouterActorCellFactory();
}
