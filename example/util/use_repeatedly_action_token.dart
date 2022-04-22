import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Create repeatedly action token
    var actionToken = RepeatedlyActionToken();

    // Create repeatedly action with repeatedly action token
    context.scheduler.scheduleRepeatedlyAction(
        interval: Duration(seconds: 1),
        action: (RepeatedlyActionContext context) {
          print(context.counter);
        },
        actionToken: actionToken);

    Future.delayed(Duration(seconds: 3), () {
      // Stop action
      actionToken.stop();
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('test_actor', TestActor());
}
