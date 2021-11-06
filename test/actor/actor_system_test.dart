import 'dart:isolate';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';

import 'actor_system/test_actor_1.dart';
import 'actor_system/test_actor_2.dart';

void main() {
  group('actor_system', () {
    late ActorSystem actorSystem;

    setUp(() async {
      actorSystem = ActorSystem('test_system');

      await actorSystem.initialize();
    });

    tearDown(() async {
      await actorSystem.dispose();
    });

    test('.actorOf(). ', () async {
      var ref = await actorSystem.actorOf('test_actor', TestActor_1());

      var subscription = ref.send('ping');

      await expectLater(
          subscription.stream
              .where((event) => event is MessageResult)
              .cast<MessageResult>()
              .map((event) => event.data),
          emitsThrough('pong'));
    });

    group('.send().', () {
      test('Use relative path.', () async {
        await actorSystem.actorOf('test_actor', TestActor_1());

        var subscription = actorSystem.send('../test_actor', 'ping');

        await expectLater(
            subscription.stream
                .where((event) => event is MessageResult)
                .cast<MessageResult>()
                .map((event) => event.data),
            emitsThrough('pong'));
      });

      test('Use absolute path.', () async {
        await actorSystem.actorOf('test_actor', TestActor_1());

        var subscription =
            actorSystem.send('test_system/root/user/test_actor', 'ping');

        await expectLater(
            subscription.stream
                .where((event) => event is MessageResult)
                .cast<MessageResult>()
                .map((event) => event.data),
            emitsThrough('pong'));
      });
    });

    test('.pause(). ', () async {
      var receivePort = ReceivePort();

      var streamQueue = StreamQueue(receivePort.asBroadcastStream());

      await actorSystem.actorOf('test_actor', TestActor_2(),
          data: {'feedbackPort': receivePort.sendPort});

      await actorSystem.pause();

      expect(await streamQueue.next, 'pause');

      receivePort.close();
    });

    test('.resume(). ', () async {
      var receivePort = ReceivePort();

      var streamQueue = StreamQueue(receivePort.asBroadcastStream());

      await actorSystem.actorOf('test_actor', TestActor_2(),
          data: {'feedbackPort': receivePort.sendPort});

      await actorSystem.pause();

      await actorSystem.resume();

      expect(await streamQueue.take(2), ['pause', 'resume']);

      receivePort.close();
    });

    test('.kill(). ', () async {
      var receivePort = ReceivePort();

      var streamQueue = StreamQueue(receivePort.asBroadcastStream());

      await actorSystem.actorOf('test_actor', TestActor_2(),
          data: {'feedbackPort': receivePort.sendPort});

      await actorSystem.kill();

      expect(await streamQueue.next, 'kill');

      receivePort.close();
    });

    test('.dispose(). ', () async {
      var receivePort = ReceivePort();

      var stream = receivePort.asBroadcastStream();

      await actorSystem.actorOf('test_actor', TestActor_2(),
          data: {'feedbackPort': receivePort.sendPort});

      await actorSystem.dispose();

      expect(await stream.first, 'kill');

      receivePort.close();
    });
  }, timeout: Timeout(Duration(seconds: 1)));
}
