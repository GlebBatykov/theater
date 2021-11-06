<div align="center">

**Languages:**
  
[![English](https://img.shields.io/badge/Language-English-blue?style=?style=flat-square)](/example/README.md)
[![Russian](https://img.shields.io/badge/Language-Russian-blue?style=?style=flat-square)](/example/README.ru.md)
  
</div>  

- [Server](#server)
  - [Multithreaded server](#multithreaded-server)
  - [Multithreaded server with worker pool](#multithreaded-server-with-worker-pool)
- [Flutter](#flutter)

You can see various simpler examples of using the package (creating an actor, sending messages, receiving messages, etc.) in the README or in the example folder on github.

# Server

## Multithreaded server

This example creates a server on Dart where incoming requests to the selected port will be distributed among the created actors (isolates) using the shared field of the HttpServer class. This can be done without using Theater, just using isolates. However, Theater helps, in addition to distributing incoming requests between isolates, to easily build more complex strategies for processing requests in other isolates, one of the implementation options is shown [here](#multithreaded-server-with-worker-pool).

```dart

// Create server receiver actor class
class ServerReceiver extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    print('Server actor with path: [' +
        context.path.toString() +
        '] is started!');

    // Create HttpServer with [shared: true] properties.
    // This is necessary to distribute the requests arriving on this port among all actors (isolates) listening on it.
    var server = await HttpServer.bind('127.0.0.1', 4467, shared: true);

    server.listen((request) async {
      print('Actor with path: ' +
          context.path.toString() +
          ', receive http request!');

      request.response.statusCode = 200;
      request.response.write('Hello, world!');
      await request.response.close();
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var actorSystem = ActorSystem('test_system');

  // Initialize actor system before work with her
  await actorSystem.initialize();

  for (var i = 0; i < 3; i++) {
    // Create receiver actor class
    await actorSystem.actorOf(
        'receiver-' + (i + 1).toString(), ServerReceiver());
  }
}

```

## Multithreaded server with worker pool

In this example, 2 actor pools are created in the actor system: receivers and workers.

The receivers in the example are those actors (isolates) that accept incoming http requests, requests arriving on port 4467 are distributed between thanks to the shared field of the HttpServer class of the dart:io standard library. The receivers in this example receive http requests, take the number value from the request parameters, and send it to the worker pool.

The workers in the example are those actors who process incoming requests, send back a response to the receivers actors (because only the isolate that accepted the http request can send a response to it). The workers are subscribed to messages of type int coming to them, then they calculate the sum of the Fibbonacci numbers up to this number and send a response to the actor who sent them this message.

Pools (pool routers) in this premier are used for receivers because of the convenience of creating a whole pool of actors of a specified size at once, and for workers this is also a means of balancing the load of messages arriving in them.

This approach allowed me to achieve higher performance when, on the http request that came to me, I performed some heavy operations that require a long time to compute.

If we take into account the query execution time, then we can achieve a balance by processing easy-to-time computations in the receivers actors (and immediately sending responses) - in order not to waste time sending information between actors (isolates), and heavy requests will be fulfilled by the workers.

```dart

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

```

# Flutter

* Section not completed *
