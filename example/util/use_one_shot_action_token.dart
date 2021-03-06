import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Create one shot action token
    var actionToken = OneShotActionToken();

    // Create one shot action in scheduler
    context.scheduler.scheduleOneShotAction(
        action: (OneShotActionContext context) {
          print('Hello, from one shot action!');
        },
        actionToken: actionToken);

    // Call action
    actionToken.call();
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
