<div align="center">

**Языки:**
  
[![English](https://img.shields.io/badge/Language-English-blue?style=?style=flat-square)](https://github.com/GlebBatykov/theater/tree/main/example/README.md)
[![Russian](https://img.shields.io/badge/Language-Russian-blue?style=?style=flat-square)](https://github.com/GlebBatykov/theater/tree/main/example/README.ru.md)
  
</div>  

- [Сервер](#сервер)
  - [Многопоточный сервер](#многопоточный-сервер)
  - [Многопоточный сервер с пулом работников](#многопоточный-сервер-с-пулом-работников)
  - [Удаленное взаимодействие при помощи Theater Remote](#удаленное-взаимодействие-при-помощи-theater-remote)
- [Flutter](#flutter)

Различные более простые примеры использования пакета (создание актора, отправка сообщений, прием сообщений и т.д) вы можете увидеть в README или в папке example на github.

# Сервер

## Многопоточный сервер

В этом примере создается сервер на Dart-е где приходящие запросы на выбранный порт будут распределятся между созданными акторами (изолятами) при помощи поля shared класса HttpServer. Подобное можно реализовать и без использования Theater, просто используя изоляты. Однако Theater помогает помимо распределения поступающих запросов между изолятами легко строить более сложные стратегии обработки запросов в других изолятах, один из вариантов реализации показан [здесь](#многопоточный-сервер-с-пулом-работников).

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
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  for (var i = 0; i < 3; i++) {
    // Create receiver actor class
    await system.actorOf('receiver-' + (i + 1).toString(), ServerReceiver());
  }
}
```

## Многопоточный сервер с пулом работников

В этом примере в системе акторов создается 2 пула акторов: получатели и работники. 

Получатели в примере это те акторы (изоляты) которые принимают поступающие http запросы, запросы поступающие на 4467 порт распределяются между благодаря полю shared класса HttpServer стандартной библиотеки dart:io. Получатели в этом примере получают http запросы, берут из параметров запроса значение number, отсылают его пулу работников.

Работники в примере это те акторы которые обрабатывают поступающие запросы, отправляют обратно ответ акторам получателям (т.к только тот изолят который принял http запрос может отправить ответ на него). Работники подписаны на сообщения типа int поступающие к ним, затем вычисляют сумму чисел Фиббоначи до этого числа и отправляют ответ тому актору который отправил им это сообщение.

Пулы (маршрутизаторы пулов) в этом примере для получателей используются из за удобства создания сразу целого пула акторов указанной величины, а для работников это так же является и средством балансировки нагрузки поступающих в них сообщений.

Подобный подход позволил мне добится более высокой производительности тогда когда на поступивший мне http запрос я выполнял некоторые тяжелые действия требующие длительного времени вычисления.

Если учитывать время выполнения запроса то можно добится баланса путем обработки легких по времени вычислений в акторах приемниках (и сразу отправлять ответы) - для того чтобы не терять время на перессылке информации между акторами (изолятами), а тяжелые запросы отсылать выполнятся работникам.

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
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create server receivers pool router
  await system.actorOf('receivers', ServerReceiverPoolRouter());

  // Create server workers pool router
  await system.actorOf('workers', ServerWorkerPoolRouter());
}
```

## Удаленное взаимодействие при помощи Theater Remote

В Theater помимо возможности отправки сообщений локальным акторам так же есть средства для удаленного взаимодействия систем акторов.

Это можно использовать для организации распределенных вычислений, к примеру разместив две системы акторов на двух разных устройствах и использовать Theater Remote для общениях их между друг другом.

Больше информации об Theater Remote есть в README.

В качестве примера рассмотрим ситуацию в которой участвуют две системы акторов, одна выступает в их общении в качестве сервера просшуливающего сообщения от других систем акторов, а вторая создает подключение к первой.

Создадим общие для этих двух систем классы, отвечающие за сериализацию и десериализацию данных:

```dart
class Message {
  final String data;

  Message(this.data);

  Message.fromJson(Map<String, dynamic> json) : data = json['data'];

  Map<String, dynamic> toJson() => {'data': data};
}

// Create serializer class
class TransportSerializer extends ActorMessageTransportSerializer {
  // Override serialize method
  @override
  String serialize(String tag, dynamic data) {
    if (data is Message) {
      return jsonEncode(data.toJson());
    } else {
      return data.toString();
    }
  }
}

// Create deserializer class
class TransportDeserializer extends ActorMessageTransportDeserializer {
  // Override deserialize method
  @override
  dynamic deserialize(String tag, String data) {
    if (tag == 'test_message') {
      return Message.fromJson(jsonDecode(data));
    } else {
      return data;
    }
  }
}
```

Создади систему выступающую в качестве сервера:

```dart
// Create actor system builder class for server
class ServerActorSystemBuilder extends ActorSystemBuilder {
  // Override build method
  @override
  ActorSystem build() {
    var name = 'test_server_system';

    // Create remote transport configuration.
    // Create in it server and set serializer and deserializer.
    var remoteConfiguration = RemoteTransportConfiguration(
        serializer: TransportSerializer(),
        deserializer: TransportDeserializer(),
        servers: [TcpServerConfiguration(address: '127.0.0.1', port: 6655)]);

    // Create actor system
    return ActorSystem(name, remoteConfiguration: remoteConfiguration);
  }
}

// Create actor which will receive messages
class ServerActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all Message type messages which actor received
    context.receive<Message>((message) async {
      print(message.data);
    });
  }
}

void main() async {
  // Create actor system with actor system builder
  var system = ServerActorSystemBuilder().build();

  // Initialize actor system before work with it
  await system.initialize();

  // Create top level actor with name 'test_server_actor'
  await system.actorOf('test_server_actor', ServerActor());
}
```

Создадим систему выступающую в качестве клиента отсылающего сообщения первой системе акторов:

```dart
// Create actor system builder class for client
class ClientActorSystemBuilder extends ActorSystemBuilder {
  // Override build method
  @override
  ActorSystem build() {
    var name = 'test_client_system';

    // Create remote transport configuration.
    // Create in it connector and set serializer and deserializer.
    var remoteConfiguration = RemoteTransportConfiguration(
        serializer: TransportSerializer(),
        deserializer: TransportDeserializer(),
        connectors: [
          TcpConnectorConfiguration(
              name: 'test_server', address: '127.0.0.1', port: 6655)
        ]);

    // Create actor system
    return ActorSystem(name, remoteConfiguration: remoteConfiguration);
  }
}

// Create actor who will send messages
class ClientActor extends UntypedActor {
  late final RemoteActorRef _ref;

  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create remote actor ref by connecting with name 'test_server'
    // to actor with actor path 'test_server_system/root/user/test_server_actor'
    _ref = await context.createRemoteActorRef(
        'test_server', 'test_server_system/root/user/test_server_actor');

    // Send message with tag 'test_message'
    _ref.send('test_message', Message('Hello, from client!'));
  }
}

void main() async {
  // Create actor system with actor system builder
  var system = ClientActorSystemBuilder().build();

  // Initialize actor system before work with it
  await system.initialize();

  // Create top level actor with name 'test_client_actor'
  await system.actorOf('test_client_actor', ClientActor());
}
```

# Flutter

Сценарии использования Theater в Flutter-е идентичны сценариям использования изолятов. В отличии от серверной стороны в Flutter-е редко возникает необходимость использовать изоляты и тем более реализовывать сложные схемы взаимодействия между ними. Поэтому в этом примере мы рассмотрим вполне стандартный пример использованя изолятов в Flutter-е, но реализуем это при помощи Theater.

В качестве примера выбран калькулятор суммы чисел Фиббоначи, считать сумму мы будем при помощи рекурсивного алгоритма, на телефоне где проводились тесты примерно до ~36 числа Фиббоначи сумма, при помощи рекурсии, вычислялась без видимых лагов в UI, однако начиная с 36 числа во время вычисления наш поток UI зависал. Чтобы не допустить зависания UI мы выносим вычисление сумм чисел Фибоначчи начиная с 36 числа в отдельный актор (изолят), а суммы Фибоначчи для чисел до 36 мы вычисляем в нашем основном потоке чтобы не терять производительность на перессылке сообщений между акторами (изолятами).

Данный пример несколько усложнен использованием пакета для внедрения зависимостей (GetIt), однако я сделал это намеренно для того чтобы показать то как я вижу использование Theater в Flutter приложениях.

Слева представлен тест без использования Theater (и изолятов в целом), а справа с Theater:

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