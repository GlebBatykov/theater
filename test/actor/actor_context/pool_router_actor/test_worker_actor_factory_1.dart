import 'package:theater/src/actor.dart';

import 'test_worker_1.dart';

class TestWorkerActorFactory_1 extends WorkerActorFactory {
  @override
  WorkerActor create() {
    return TestWorkerActor_1();
  }
}
