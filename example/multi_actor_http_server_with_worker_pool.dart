import 'dart:io';

import 'package:theater/theater.dart';

// Create server receiver actor class
class ServerReceiver extends WorkerActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(WorkerActorContext context) async {
    // Create HttpServer with [shared: true] properties.
    // This is necessary to distribute the requests arriving on this port among all actors (isolates) listening on it.
    var server = await HttpServer.bind('127.0.0.1', 4471, shared: true);

    server.listen((request) async {
      var number = int.parse(request.requestedUri.queryParameters['number']!);

      // Send message to worker pool router
      var subscription = context.send('test_system/root/user/workers', number);

      // Set onResponse handler
      subscription.onResponse((response) {
        if (response is MessageResult) {
          request.response.statusCode = 200;
          request.response.write(response.data);
        } else {
          request.response.statusCode = 400;
        }

        request.response.close();
      });
    });
  }
}

// Create server worker actor class
class ServerWorker extends WorkerActor {
  int _fibonacci(int number) =>
      number <= 2 ? 1 : _fibonacci(number - 1) + _fibonacci(number - 2);

  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(WorkerActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<int>((message) async {
      var result = _fibonacci(message);

      return MessageResult(data: result);
    });
  }
}

// Create server receiver factory class
class ServerReceiverFactory extends WorkerActorFactory {
  @override
  ServerReceiver create() => ServerReceiver();
}

// Create server worker factory class
class ServerWorkerFactory extends WorkerActorFactory {
  @override
  ServerWorker create() => ServerWorker();
}

// Create server receiver pool router class
class ServerReceiverPoolRouter extends PoolRouterActor {
  @override
  PoolDeployementStrategy createDeployementStrategy() {
    return PoolDeployementStrategy(
        workerFactory: ServerReceiverFactory(),
        routingStrategy: PoolRoutingStrategy.roundRobin,
        poolSize: 2);
  }
}

// Create server worker pool router class
class ServerWorkerPoolRouter extends PoolRouterActor {
  @override
  PoolDeployementStrategy createDeployementStrategy() {
    return PoolDeployementStrategy(
        workerFactory: ServerWorkerFactory(),
        routingStrategy: PoolRoutingStrategy.roundRobin,
        poolSize: 4);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var actorSystem = ActorSystem('test_system');

  // Initialize actor system before work with her
  await actorSystem.initialize();

  // Create server receivers pool router
  await actorSystem.actorOf('receivers', ServerReceiverPoolRouter());

  // Create server workers pool router
  await actorSystem.actorOf('workers', ServerWorkerPoolRouter());
}
