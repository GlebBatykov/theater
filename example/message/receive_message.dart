import 'package:theater/theater.dart';

// If you need use your class as message type
class Dog {
  final String name;

  Dog(this.name);
}

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);
    });

    // Set handler to all int type messages which actor received
    context.receive<int>((message) async {
      print(message);
    });

    context.receive<Dog>((message) async {
      print('Dog name: ' + message.name);
    });
  }
}
