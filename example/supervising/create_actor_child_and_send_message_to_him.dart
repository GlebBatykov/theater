import 'package:theater/theater.dart';

class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(context) async {
    // Create child with name 'second_test_actor'
    var ref = await context.actorOf('second_test_actor', SecondTestActor());

    // Send message
    ref.send('Luke, I am your father.');
  }
}

class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      if (message == 'Luke, I am your father.') {
        print('Nooooooo!');
      }
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());
}
