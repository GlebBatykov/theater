import 'package:test/test.dart';
import 'package:theater/src/actor.dart';
import 'package:theater/src/actor_system.dart';

import 'actor_context_test_data.dart';

abstract class ActorContextTester<T extends ActorContext> {
  Future<void> killTest(ActorContextTestData<T> data) async {
    data.actorContext.kill();

    expect(await data.supervisorMessagePort.first, isA<ActorWantsToDie>());
  }

  Future<void> sendToTopicTest(ActorContextTestData<T> data) async {
    data.actorContext.sendToTopic('test_topic', 'test');

    var event = await data.actorSystemSendPort
        .firstWhere((element) => element is ActorSystemAddTopicMessage);

    expect(event, isA<ActorSystemAddTopicMessage>());
    expect(event.message.topicName, 'test_topic');
    expect(event.message.data, 'test');
  }

  Future<void> sendAndSubscribeWithAbsolutePath(ActorContextTestData<T> data);

  Future<void> sendAndSubscribeWithRelativePath(ActorContextTestData<T> data);

  Future<void> sendAndSubscribeToHimself(ActorContextTestData<T> data);
}
