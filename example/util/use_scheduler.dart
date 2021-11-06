import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Create cancellation token
    var cancellationToken = CancellationToken();

    // Create first repeatedly action in scheduler
    context.scheduler.scheduleActionRepeatedly(
        interval: Duration(seconds: 1),
        action: () {
          print('Hello, from first action!');
        },
        cancellationToken: cancellationToken);

    // Create second repeatedly action in scheduler
    context.scheduler.scheduleActionRepeatedly(
        initDelay: Duration(seconds: 1),
        interval: Duration(milliseconds: 500),
        action: () {
          print('Hello, from second action!');
        },
        cancellationToken: cancellationToken);

    Future.delayed(Duration(seconds: 3), () {
      // Cancel actions after 3 seconds
      cancellationToken.cancel();
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
  await system.initialize();

  // Create top-level actor in actor system with name 'test_actor'
  await system.actorOf('test_actor', TestActor());
}
