part of theater.actor;

/// Class is used by initialization in [PoolRouterActor].
class PoolDeployementStrategy extends RouterDeployementStrategy {
  /// Routing strategy is used by message routing in [PoolRouterActor].
  final PoolRoutingStrategy routingStrategy;

  /// Instanse of [WorkerActorFactory] used by creating worker pool in [PoolRouterActor].
  final WorkerActorFactory workerFactory;

  /// Size of worker pool in [PoolRouterActor].
  late final int poolSize;

  /// Some data that is transferred to all worker actor in pool.
  final Map<String, dynamic>? data;

  PoolDeployementStrategy(
      {required this.workerFactory,
      required this.routingStrategy,
      int poolSize = 2,
      this.data}) {
    if (poolSize >= 0) {
      this.poolSize = poolSize;
    } else {
      throw PoolDeployementStrategyException(
          message: 'pool size should not be negative.');
    }
  }
}
