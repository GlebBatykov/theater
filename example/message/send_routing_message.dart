import 'package:theater/theater.dart';

class MyActor extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    await context.actorOf('second', MySecondActor());

    var subscription = context.send('../second', 'Hello, from actor!');

    subscription.onResponse((response) {
      if (response is MessageResult) {
        print(response.data);
      }
    });
  }
}

class MySecondActor extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    context.receive<String>((message) async {
      print(message);

      return MessageResult(data: 'Hello, from second actor!');
    });
  }
}

void main(List<String> arguments) async {
  var system = ActorSystem('system');

  await system.initialize();

  await system.actorOf('actor', MyActor());
}
