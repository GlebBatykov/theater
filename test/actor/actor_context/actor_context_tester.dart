import 'package:test/test.dart';
import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';

import 'actor_context_test_data.dart';

abstract class ActorContextTester<T extends ActorContext> {
  Future<void> killTest(ActorContextTestData<T> data) async {
    data.actorContext.kill();

    expect(await data.supervisorMessagePort.first, isA<ActorWantsToDie>());
  }

  Future<void> sendToTopicTest(ActorContextTestData<T> data) async {
    data.actorContext.sendToTopic('test_topic', 'test');

    var message = await data.actorSystemMessagePort.first;

    expect(message, isA<ActorSystemTopicMessage>());
    expect(message.topicName, 'test_topic');
    expect(message.data, 'test');
  }

  Future<void> sendWithAbsolutePath(ActorContextTestData<T> data);

  Future<void> sendWithRelativePath(ActorContextTestData<T> data);

  Future<void> sendToHimself(ActorContextTestData<T> data);
}
