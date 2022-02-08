import 'package:theater/theater.dart';

// Create first actor class
class FirstTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Send message to actor system topic with name 'first_test_topic' and get subscription to response
    var subscription =
        context.sendToTopicAndSubscribe('first_test_topic', 'This is String');

    // Set handler to response
    subscription.onResponse((response) {
      if (response is MessageResult) {
        print(response.data);
      }
    });
  }
}

// Create second actor class
class SecondTestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    // Send message to actor system topic with name 'second_test_topic'
    context.sendToTopic('second_test_topic', 123.4);
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var system = ActorSystem('test_system');

  // Initialize actor system before work with it
  await system.initialize();

  // Create handler to messages as String from topic with name 'first_test_topic'
  system.listenTopic<String>('first_test_topic', (message) async {
    print(message);

    return MessageResult(data: 'Hello, from main!');
  });

  // Create handler to messages as double from topic with name 'second_test_topic'
  system.listenTopic<double>('second_test_topic', (message) async {
    print(message * 2);

    return;
  });

  // Create top-level actor in actor system with name 'first_test_actor'
  await system.actorOf('first_test_actor', FirstTestActor());

  // Create top-level actor in actor system with name 'second_test_actor'
  await system.actorOf('second_test_actor', SecondTestActor());
}
