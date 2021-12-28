// Create actor class
import 'package:theater/theater.dart';

class TestActor extends UntypedActor {
  final String _message;

  TestActor({required String message}) : _message = message;

  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    print(_message);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor(message: 'Hello, actor world!'));
}
