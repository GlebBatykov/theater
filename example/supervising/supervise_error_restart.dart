import 'dart:math';

import 'package:theater/theater.dart';

// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create child actor with name 'second_test_actor'
    await context.actorOf('second_test_actor', SecondTestActor());
  }

  // Override createSupervisorStrategy method, set decider and restartDelay
  @override
  SupervisorStrategy createSupervisorStrategy() =>
      OneForOneStrategy(decider: TestDecider());
}

// Create decider class
class TestDecider extends Decider {
  @override
  Directive decide(Object object) {
    if (object is FormatException) {
      return RestartDirective(delay: Duration(milliseconds: 500));
    } else {
      return EscalateDirective();
    }
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    print('Hello, from second test actor!');

    // Someone random factor or something where restarting might come in handy
    if (Random().nextBool()) {
      throw FormatException();
    }
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
