<div align="center">

**Языки:**
  
[![English](https://img.shields.io/badge/Language-English-blue?style=?style=flat-square)](/example/README.md)
[![Russian](https://img.shields.io/badge/Language-Russian-blue?style=?style=flat-square)](/example/README.ru.md)
  
</div>  

- [Сервер](#сервер)
  - [Многопоточный сервер](#многопоточный-сервер)
  - [Многопоточный сервер с пулом работников](#многопоточный-сервер-с-пулом-работников)
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

## Многопоточный сервер с пулом работников

В этом примере в системе акторов создается 2 пула акторов: получатели и работники. 

Получатели в примере это те акторы (изоляты) которые принимают поступающие http запросы, запросы поступающие на 4467 порт распределяются между благодаря полю shared класса HttpServer стандартной библиотеки dart:io. Получатели в этом примере получают http запросы, берут из параметров запроса значение number, отсылают его пулу работников.

Работники в примере это те акторы которые обрабатывают поступающие запросы, отправляют обратно ответ акторам получателям (т.к только тот изолят который принял http запрос может отправить ответ на него). Работники подписаны на сообщения типа int поступающие к ним, затем вычисляют сумму чисел Фиббоначи до этого числа и отправляют ответ тому актору который отправил им это сообщение.

Пулы (маршрутизаторы пулов) в этом премере для получателей используются из за удобства создания сразу целого пула акторов указанной величины, а для работников это так же является и средством балансировки нагрузки поступающих в них сообщений.

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

* Раздел не дописан *
