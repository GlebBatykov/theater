import 'dart:async';

import 'package:theater/theater.dart';

// In this example actor with name 'second_test_actor' throw FormatException.
//
// By default, each supervisor actor has a supervisor strategy that handles
// the exception by passing the error to an upstream actor.
//
// However, in this example we will create our own decider, our own supervisor strategy,
// and if the exception we handle is FormatException we will resume the work of the actor.
//
// After an exception occurs in an actor. If [stopAfterError] field of supervisor strategy is true -
// its work will be paused before it supervisor actor decides what needs to be done with it.
// The method onPause of the actor in which the exception was thrown will be triggered.
//
// Supervisor actor (FirstTestActor) with the help of TestDecider will decide that the actor in which the exception occurred needs to be resumed.
// The onResume method of SecondTestActor will call.

// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    print('Hello, from actor!');

    // Create child with name 'second_test_actor'
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
      return IgnoreDirective();
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
    Timer.periodic(Duration(seconds: 1), (timer) {
      print('Hello, from second actor!');
    });

    // Throw exception
    Future.delayed(Duration(seconds: 2), () {
      throw FormatException();
    });
  }

  // Override onPause method which will be executed before actor paused
  @override
  void onPause(UntypedActorContext context) {
    print('Second test actor is paused!');
  }

  // Override onResume method which will be executed after actor resumed
  @override
  void onResume(UntypedActorContext context) {
    print('Second test actor is resumed!');
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());
}
