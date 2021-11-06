import 'package:theater/src/actor.dart';
import 'package:theater/src/routing.dart';

import 'test_worker_actor_factory_1.dart';

class TestPoolRouterActor_1 extends PoolRouterActor {
  @override
  PoolDeployementStrategy createDeployementStrategy() {
    return PoolDeployementStrategy(
        workerFactory: TestWorkerActorFactory_1(),
        routingStrategy: PoolRoutingStrategy.roundRobin,
        poolSize: 15);
  }
}
