import 'package:test/test.dart';
import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';

import 'actor_context_test_data.dart';
import 'actor_context_tester.dart';

class WorkerActorContextTester<T extends WorkerActorContext>
    extends ActorContextTester<T> {
  @override
  Future<void> sendWithAbsolutePath(ActorContextTestData<T> data) async {
    data.actorContext.send('test_system/test_root', 'Hello, test world!');

    var message = await data.supervisorMessagePort.first;

    expect(message, isA<ActorRoutingMessage>());
    expect((message as ActorRoutingMessage).data, 'Hello, test world!');
  }

  @override
  Future<void> sendWithRelativePath(ActorContextTestData<T> data) async {
    var subscription =
        data.actorContext.send('../some_actor', 'Hello, test world!');

    var response = await subscription.stream.first;

    expect(response, isA<RecipientNotFoundResult>());
  }

  @override
  Future<void> sendToHimself(ActorContextTestData<T> data) async {
    data.actorContext
        .send('test_system/test_root/worker', 'Hello, test world!');

    var message = await data.mailbox.mailboxMessages.first;

    expect(message.data, 'Hello, test world!');
  }
}
