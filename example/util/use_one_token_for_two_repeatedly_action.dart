import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create repeatedly action token
    var actionToken = RepeatedlyActionToken();

    // Create repeatedly action with repeatedly action token
    context.scheduler.scheduleRepeatedlyAction(
        interval: Duration(seconds: 1),
        action: (RepeatedlyActionContext context) {
          print('Hello, from first action!');
        },
        onStop: (RepeatedlyActionContext context) {
          print('First action stopped!');
        },
        onResume: (RepeatedlyActionContext context) {
          print('First action resumed!');
        },
        actionToken: actionToken);

    // Create second repeatedly action with repeatedly action token
    context.scheduler.scheduleRepeatedlyAction(
        interval: Duration(seconds: 1),
        action: (RepeatedlyActionContext context) {
          print('Hello, from second action!');
        },
        onStop: (RepeatedlyActionContext context) {
          print('Second action stopped!');
        },
        onResume: (RepeatedlyActionContext context) {
          print('Second action resumed!');
        },
        actionToken: actionToken);

    Future.delayed(Duration(seconds: 2), () {
      // Stop action
      actionToken.stop();

      Future.delayed(Duration(seconds: 3), () {
        // Resume action
        actionToken.resume();
      });
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
