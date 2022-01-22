import 'dart:isolate';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';

import '../actor_context_test_data.dart';
import '../actor_context_tester.dart';
import '../actor_parent_tester.dart';

class PoolRouterActorContextTester<T extends PoolRouterActorContext>
    extends ActorContextTester<T> with ActorParentTester<T> {
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
    var subscription =
        data.actorContext.sendAndSubscribe('../worker-1', 'Hello, test world!');

    var result = await subscription.stream.first;

    expect(result, isA<RecipientNotFoundResult>());
  }

  @override
  Future<void> sendAndSubscribeToHimself(ActorContextTestData<T> data) async {
    data.actorContext.send('test_system/test_root/test', 'Hello, test world!');

    expect(
        (await data.mailbox.mailboxMessages.first).data, 'Hello, test world!');
  }

  @override
  Future<void> killChildrenTest(ActorContextTestData<T> data) async {
    await super.killChildrenTest(data);
  }

  @override
  Future<void> pauseChildrenTest(ActorContextTestData<T> data) async {
    await super.pauseChildrenTest(data);
  }

  @override
  Future<void> resumeChildrenTest(ActorContextTestData<T> data) async {
    await super.resumeChildrenTest(data);
  }

  @override
  Future<void> restartChildrenTest(ActorContextTestData<T> data) async {
    await super.restartChildrenTest(data);
  }

  Future<void> routingBroadcastTest(ActorContextTestData<T> data) async {
    var receivePort = ReceivePort();

    var streamQueue = StreamQueue(receivePort);

    data.isolateReceivePort!.sendPort.send(MailboxMessage('Hello, test world!',
        feedbackPort: receivePort.sendPort));

    expect(
        List.of((await streamQueue.take(5))
            .cast<MessageResult>()
            .map((e) => e.data)),
        List.generate(5, (index) => 'Hello, test world!'));

    receivePort.close();
  }

  Future<void> routingRandomTest(ActorContextTestData<T> data) async {
    var receivePort = ReceivePort();

    var streamQueue = StreamQueue(receivePort);

    for (var i = 0; i < 5; i++) {
      data.isolateReceivePort!.sendPort.send(MailboxMessage(
          'Hello, test world!',
          feedbackPort: receivePort.sendPort));
    }

    var stopwatch = Stopwatch()..start();

    await streamQueue.take(5);

    stopwatch.stop();

    await streamQueue.cancel();

    expect(stopwatch.elapsedMilliseconds, inExclusiveRange(100, 400));

    receivePort.close();
  }

  Future<void> routingRoundRobinTest(ActorContextTestData<T> data) async {
    var receivePort = ReceivePort();

    var streamQueue = StreamQueue(receivePort);

    for (var i = 0; i < 5; i++) {
      data.isolateReceivePort!.sendPort.send(MailboxMessage(
          'Hello, test world!',
          feedbackPort: receivePort.sendPort));
    }

    var stopwatch = Stopwatch()..start();

    await streamQueue.take(5);

    stopwatch.stop();

    await streamQueue.cancel();

    expect(stopwatch.elapsedMilliseconds, inExclusiveRange(100, 150));

    receivePort.close();
  }

  Future<void> routingBalancingTest(ActorContextTestData<T> data) async {
    var receivePort = ReceivePort();

    var streamQueue = StreamQueue(receivePort);

    for (var i = 0; i < 5; i++) {
      data.isolateReceivePort!.sendPort.send(MailboxMessage(
          'Hello, test world!',
          feedbackPort: receivePort.sendPort));
    }

    var stopwatch = Stopwatch()..start();

    await streamQueue.take(5);

    stopwatch.stop();

    await streamQueue.cancel();

    expect(stopwatch.elapsedMilliseconds, inExclusiveRange(100, 150));

    receivePort.close();
  }
}
