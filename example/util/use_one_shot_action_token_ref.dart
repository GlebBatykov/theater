import 'package:theater/theater.dart';

// Create first actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create one shot action token
    var actionToken = OneShotActionToken();

    // Create one shot action in scheduler
    context.scheduler.scheduleOneShotAction(
        action: (OneShotActionContext context) {
          print('Hello, from one shot action!');
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
  Future<void> onStart(UntypedActorContext context) async {
    // Get action token ref from actor store
    var ref = context.store.get<OneShotActionTokenRef>('action_token_ref');

    // Call action in other actor
    ref.call();
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
