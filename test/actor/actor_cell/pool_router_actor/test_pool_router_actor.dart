import 'dart:isolate';

import 'package:theater/src/actor.dart';
import 'package:theater/src/routing.dart';

class TestPoolRouterActor_1 extends PoolRouterActor {
  @override
  Future<void> onStart(context) async {
    var feedbackPort = context.store.get<SendPort>('feedbackPort');

    feedbackPort.send('start');
  }

  @override
  Future<void> onPause(context) async {
    var feedbackPort = context.store.get<SendPort>('feedbackPort');

    feedbackPort.send('pause');
  }

  @override
  Future<void> onResume(context) async {
    var feedbackPort = context.store.get<SendPort>('feedbackPort');

    feedbackPort.send('resume');
  }

  @override
  Future<void> onKill(context) async {
    var feedbackPort = context.store.get<SendPort>('feedbackPort');

    feedbackPort.send('kill');
  }

  @override
  PoolDeployementStrategy createDeployementStrategy() {
    return PoolDeployementStrategy(
      routingStrategy: PoolRoutingStrategy.broadcast,
      workerFactory: TestWorkerFactory(),
      poolSize: 0,
    );
  }
}

class TestWorkerActor_1 extends WorkerActor {}

class TestWorkerFactory extends WorkerActorFactory<TestWorkerActor_1> {
  @override
  TestWorkerActor_1 create() => TestWorkerActor_1();
}
