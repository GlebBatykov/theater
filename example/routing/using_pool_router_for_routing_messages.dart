import 'dart:async';

import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    // Create router actor and get ref to him
    var ref = await context.actorOf('test_router', TestRouter());

    for (var i = 0; i < 5; i++) {
      // Send message to pool router
      ref.send('Hello message №' + i.toString());
    }
  }
}

// Create pool router class
class TestRouter extends PoolRouterActor {
  // Override createDeployementStrategy method, configurate group router actor
  @override
  PoolDeployementStrategy createDeployementStrategy() {
    return PoolDeployementStrategy(
        workerFactory: TestWorkerFactory(),
        routingStrategy: PoolRoutingStrategy.random,
        poolSize: 5);
  }
}

// Create actor worker class
class TestWorker extends WorkerActor {
  @override
  Future<void> onStart(context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print('Received by the worker with path: ' +
          context.path.toString() +
          ', message: ' +
          message);
    });
  }
}

// Create worker factory class
class TestWorkerFactory extends WorkerActorFactory {
  @override
  WorkerActor create() => TestWorker();
}

void main(List<String> arguments) async {
  // Create actor system
  var actorSystem = ActorSystem('test_system');

  // Initialize actor system before work with it
  await actorSystem.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await actorSystem.actorOf('test_actor', TestActor());
}
