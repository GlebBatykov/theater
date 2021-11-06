import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    // Set handler to all String type messages which actor received
    context.receive<String>((message) async {
      print(message);
    });

    // Set handler to all int type messages which actor received
    context.receive<int>((message) async {
      print(message);
    });
  }

  // Override createMailboxFactory method
  @override
  MailboxFactory createMailboxFactory() => PriorityReliableMailboxFactory(
      priorityGenerator: TestPriorityGenerator());
}

// Create priority generator class
class TestPriorityGenerator extends PriorityGenerator {
  @override
  int generatePriority(object) {
    if (object is String) {
      return 1;
    } else {
      return 0;
    }
  }
}

void main(List<String> arguments) async {
  // Create actor system with name 'test_system'
  var system = ActorSystem('test_system');

  // Initialize actor system before work with her
  await system.initialize();

  // Create top-level actor in actor system with name 'hello_actor' and get ref to it
  var ref = await system.actorOf('test_actor', TestActor());

  for (var i = 0; i < 5; i++) {
    ref.send(i < 3 ? i : i.toString()); // Send messages 0, 1, 2, "3", "4"
  }
}
