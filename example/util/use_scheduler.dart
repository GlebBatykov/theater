import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create first repeatedly action in scheduler
    context.scheduler.scheduleRepeatedlyAction(
        interval: Duration(seconds: 1),
        action: (RepeatedlyActionContext actionContext) {
          print('Hello, from first action!');
        });

    // Create second repeatedly action in scheduler
    context.scheduler.scheduleRepeatedlyAction(
        initialDelay: Duration(seconds: 1),
        interval: Duration(milliseconds: 500),
        action: (RepeatedlyActionContext actionContext) {
          print('Hello, from second action!');
        });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
