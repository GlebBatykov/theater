import 'package:test/test.dart';
import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';

import 'actor_context_test_data.dart';
import 'actor_parent_tester.dart';
import 'node_actor_ref_factory_tester.dart';
import 'actor_context_tester.dart';
import 'test_actor/test_untyped_actor_1.dart';
import 'test_actor/test_untyped_actor_2.dart';

class UntypedActorContextTester<T extends UntypedActorContext>
    extends ActorContextTester<T>
    with NodeActorRefFactoryTester<T>, ActorParentTester<T> {
  @override
  Future<void> sendAndSubscribeWithAbsolutePath(
      ActorContextTestData<T> data) async {
    data.actorContext.send('test_system/test_root', 'Hello, test world!');

    var message = await data.parentMailbox!.mailboxMessages.first;

    expect(message.data, 'Hello, test world!');
  }

  @override
  Future<void> sendAndSubscribeWithRelativePath(
      ActorContextTestData<T> data) async {
    await data.actorContext.actorOf('test_child', TestUntypedActor_1());

    var subscription = data.actorContext
        .sendAndSubscribe('../test_child', 'Hello, test world!');

    var result = await subscription.stream.first;

    expect(result, isA<MessageResult>());
    expect((result as MessageResult).data, 'Hello, test world!');
  }

  @override
  Future<void> sendAndSubscribeToHimself(ActorContextTestData<T> data) async {
    data.actorContext.send('test_system/test_root/test', 'Hello, test world!');

    var message = await data.mailbox.mailboxMessages.first;

    expect(message.data, 'Hello, test world!');
  }

  @override
  Future<void> killChildrenTest(ActorContextTestData<T> data) async {
    for (var i = 0; i < 5; i++) {
      await data.actorContext.actorOf(
          'test_child_' + i.toString(), TestUntypedActor_2(),
          data: {'feedbackPort': data.feedbackPort!.sendPort});
    }

    await super.killChildrenTest(data);
  }

  @override
  Future<void> pauseChildrenTest(ActorContextTestData<T> data) async {
    for (var i = 0; i < 5; i++) {
      await data.actorContext.actorOf(
          'test_child_' + i.toString(), TestUntypedActor_2(),
          data: {'feedbackPort': data.feedbackPort!.sendPort});
    }

    await super.pauseChildrenTest(data);
  }

  @override
  Future<void> resumeChildrenTest(ActorContextTestData<T> data) async {
    for (var i = 0; i < 5; i++) {
      await data.actorContext.actorOf(
          'test_child_' + i.toString(), TestUntypedActor_2(),
          data: {'feedbackPort': data.feedbackPort!.sendPort});
    }

    await super.resumeChildrenTest(data);
  }

  @override
  Future<void> restartChildrenTest(ActorContextTestData<T> data) async {
    for (var i = 0; i < 5; i++) {
      await data.actorContext.actorOf(
          'test_child_' + i.toString(), TestUntypedActor_2(),
          data: {'feedbackPort': data.feedbackPort!.sendPort});
    }

    await super.restartChildrenTest(data);
  }
}
