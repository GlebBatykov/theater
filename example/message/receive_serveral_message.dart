import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to only 5 following messages of type String, then print 'Hello, from test actor!' message.
    // Method [receiveSeveral] return Future and you can wait or not wait him.
    context.receiveSeveral<String>(5, (message) async {
      print(message);

      return;
    }).then((_) {
      print('Hello, from test actor!');
    }).ignore();
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  var ref = await system.actorOf('test_actor', TestActor());

  // Send messages
  Stream.fromIterable(List.generate(5, (index) => index.toString()))
      .listen((event) {
    ref.send(event);
  });
}
