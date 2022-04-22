import 'package:theater/theater.dart';

// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create repeatedly action token
    var actionToken = RepeatedlyActionToken();

    // Create repeatedly action in scheduler with repeatedly action token
    context.scheduler.scheduleRepeatedlyAction(
        interval: Duration(seconds: 1),
        action: (RepeatedlyActionContext context) {
          print(context.counter);
        },
        actionToken: actionToken);

    var data = <String, dynamic>{'action_token_ref': actionToken.ref};

    // Create child actor with name 'second_test_actor' and pass a ref during initialization
    await context.actorOf('second_test_actor', SecondTestActor(), data: data);
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Get action token ref from actor store
    var ref = context.store.get<RepeatedlyActionTokenRef>('action_token_ref');

    Future.delayed(Duration(seconds: 5), () {
      // Stop action in other actor
      ref.stop();
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());
}
