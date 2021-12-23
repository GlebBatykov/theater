<div align="center">

**Languages:**
  
[![English](https://img.shields.io/badge/Language-English-blue?style=?style=flat-square)](https://github.com/GlebBatykov/theater/tree/main/example/README.md)
[![Russian](https://img.shields.io/badge/Language-Russian-blue?style=?style=flat-square)](https://github.com/GlebBatykov/theater/tree/main/example/README.ru.md)
  
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

  // Initialize actor system before work with it
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

Pools (pool routers) in this example are used for receivers because of the convenience of creating a whole pool of actors of a specified size at once, and for workers this is also a means of balancing the load of messages arriving in them.

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

  // Initialize actor system before work with it
  await actorSystem.initialize();

  // Create server receivers pool router
  await actorSystem.actorOf('receivers', ServerReceiverPoolRouter());

  // Create server workers pool router
  await actorSystem.actorOf('workers', ServerWorkerPoolRouter());
}
```

# Flutter

Theater use cases in Flutter are identical to isolates use scenarios. Unlike the server side, in Flutter, there is rarely a need to use isolates, and even more so to implement complex schemes of interaction between them. Therefore, in this example, we will consider a fairly standard example of using isolates in Flutter, but we will implement it using Theater.

As an example, the calculator of the sum of Fibonacci numbers was chosen, we will calculate the sum using a recursive algorithm, on the phone where tests were carried out up to about ~ 36 Fibbonacci numbers, the sum, using recursion, was calculated without visible lags in the UI, however, starting from the 36th number during the calculation our UI thread was hanging. In order to prevent UI freezing, we move the calculation of the Fibonacci sums starting from the 36th number into a separate actor (isolate), and we calculate the Fibonacci sums for numbers up to 36 in our main thread so as not to lose performance when sending messages between actors (isolates).

This example is somewhat complicated by the use of the package for dependency injection (GetIt), however, I did it on purpose in order to show how I see the use of Theater in Flutter applications.

On the left, the test is presented without the use of Theater (and isolates in general), and on the right with Theater:

<div align="center">
  <img src="https://i.ibb.co/LPn96mP/In-Ui-Thread.gif" width="20%" display="inline-block"/>
  <img src="https://i.ibb.co/nQQVMc5/In-Other-Isolate.gif" width="20%" display="inline-block"/>
</div>

```dart
void main() async {
  // Initialize dependencies
  await InjectionContainer.initialize();

  // Run application
  runApp(const Application());
}

abstract class InjectionContainer {
  static Future<void> initialize() async {
    // Get [GetIt] instance
    var getIt = GetIt.instance;

    // Register dependency of [ActorSystem]
    getIt.registerLazySingletonAsync<ActorSystem>(() async {
      // Create actor system
      var system = ActorSystem('test_system');

      // Initialize actor system before work with it
      await system.initialize();

      return system;
    }, dispose: (system) async {
      // Dispose actor system
      await system.dispose();
    });

    // Register dependency of [LocalActorRef] with instance name 'test_actor_ref' to actor with name 'test_actor'
    getIt.registerLazySingletonAsync<LocalActorRef>(() async {
      // Get [ActorSystem] dependency for [GetIt]
      var system = await getIt.getAsync<ActorSystem>();

      // Create top-level actor in actor system with name 'test_actor'
      var ref = await system.actorOf('test_actor', TestActor());

      return ref;
    }, instanceName: 'test_actor_ref');
  }
}

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all int type messages which actor received
    context.receive<int>((message) async {
      // Calculate result
      var result = Fibonacci.calculate(message);

      // Send message result
      return MessageResult(data: result);
    });
  }
}

abstract class Fibonacci {
  static int calculate(int number) =>
      number <= 2 ? 1 : calculate(number - 1) + calculate(number - 2);
}

class Application extends StatelessWidget {
  const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_theater_example_application',
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              FibonacciCalculator(),
              Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: SizedBox(
                    width: 200,
                    height: 150,
                    child: TestAnimation(),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class FibonacciCalculator extends StatefulWidget {
  const FibonacciCalculator({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FibonacciCalculatorState();
}

class _FibonacciCalculatorState extends State<FibonacciCalculator> {
  final TextEditingController _textEditingController = TextEditingController();

  late final LocalActorRef _ref;

  String _result = '';

  // Get dependency for [GetIt]
  Future<void> _initialize() async {
    // Get instance of [LocalActorRef] with name 'test_actor_ref'
    _ref = await GetIt.instance
        .getAsync<LocalActorRef>(instanceName: 'test_actor_ref');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialize(),
        builder: (context, snapshot) {
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                const Text('Fibonacci calculator',
                    style: TextStyle(fontSize: 20)),
                TextFormField(
                    controller: _textEditingController,
                    keyboardType: TextInputType.number),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: ElevatedButton(
                      style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(125, 50))),
                      onPressed: () async {
                        if (_textEditingController.text.isNotEmpty) {
                          var number = int.parse(_textEditingController.text);

                          late int result;

                          // Check number
                          if (number < 36) {
                            result = Fibonacci.calculate(number);
                          } else {
                            // Send message to actor
                            var subscription = _ref.send(number);

                            // Wait response from actor
                            var response = await subscription.stream.first;

                            result = (response as MessageResult).data;
                          }

                          setState(() {
                            // Set new state of _result
                            _result = result.toString();
                          });
                        } else {
                          // Show snack bar if field is empty
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Field is empty')));
                        }
                      },
                      child: const Text('Calculate',
                          style: TextStyle(fontSize: 16))),
                ),
                if (_result.isNotEmpty)
                  Text('Result: ' + _result,
                      style: const TextStyle(fontSize: 16))
              ]));
        });
  }
}

// Widget of animation
class TestAnimation extends StatefulWidget {
  const TestAnimation({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TestAnimationState();
}

class _TestAnimationState extends State<TestAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat(reverse: true);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      var biggest = constrains.biggest;

      return Stack(
        children: [
          PositionedTransition(
            rect: RelativeRectTween(
                    begin: RelativeRect.fromSize(
                        const Rect.fromLTWH(0, 0, 25, 25), biggest),
                    end: RelativeRect.fromSize(
                        Rect.fromLTWH(
                            biggest.width - 25, biggest.height - 25, 25, 25),
                        biggest))
                .animate(CurvedAnimation(
                    parent: _animationController, curve: Curves.ease)),
            child: Container(
              color: Colors.blue,
            ),
          )
        ],
      );
    });
  }
}
```
