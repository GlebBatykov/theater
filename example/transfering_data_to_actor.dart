import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) async {
    // Get message from actor store
    var message = context.store.get<String>('message');

    print(message);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  var data = <String, dynamic>{'message': 'Hello, actor world'};

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor(), data: data);
}
