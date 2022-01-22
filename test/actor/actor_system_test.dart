import 'dart:async';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:theater/src/actor.dart';
import 'package:theater/src/actor_system.dart';
import 'package:theater/src/dispatch.dart';

import 'actor_system/test_actor_1.dart';
import 'actor_system/test_actor_2.dart';
import 'actor_system/test_actor_3.dart';

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

    test(
        '.actorOf(). Creates top-level actor with actor system, sends \'ping\' message to him and receives \'pong\' message.',
        () async {
      var ref = await actorSystem.actorOf('test_actor', TestActor_1());

      var subscription = ref.sendAndSubscribe('ping');

      await expectLater(
          subscription.stream
              .where((event) => event is MessageResult)
              .cast<MessageResult>()
              .map((event) => event.data),
          emitsThrough('pong'));
    });

    group('.sendAndSubscribe().', () {
      test(
          'Use relative path. Sends message to actor using the actor system, using relative path to actor.',
          () async {
        await actorSystem.actorOf('test_actor', TestActor_1());

        var subscription =
            actorSystem.sendAndSubscribe('../test_actor', 'ping');

        await expectLater(
            subscription.stream
                .where((event) => event is MessageResult)
                .cast<MessageResult>()
                .map((event) => event.data),
            emitsThrough('pong'));
      });

      test(
          'Use absolute path. Sends message to actor using the actor system, using absolute path to actor.',
          () async {
        await actorSystem.actorOf('test_actor', TestActor_1());

        var subscription = actorSystem.sendAndSubscribe(
            'test_system/root/user/test_actor', 'ping');

        await expectLater(
            subscription.stream
                .where((event) => event is MessageResult)
                .cast<MessageResult>()
                .map((event) => event.data),
            emitsThrough('pong'));
      });
    });

    test(
        '.listenTopic(). Creates top level actor who send message to topic with name \'test_topic\', receive message from topic with name \'test_topic\'',
        () async {
      var streamController = StreamController();

      actorSystem.listenTopic('test_topic', (message) async {
        streamController.sink.add(message);
      });

      await actorSystem.actorOf('test_actor', TestActor_3());

      expect(await streamController.stream.first, 'test');

      await streamController.close();
    });

    test(
        '.pause(). Pauses all actors in actor system, receives message from actor when will it be stopped.',
        () async {
      var receivePort = ReceivePort();

      var streamQueue = StreamQueue(receivePort.asBroadcastStream());

      await actorSystem.actorOf('test_actor', TestActor_2(),
          data: {'feedbackPort': receivePort.sendPort});

      await actorSystem.pause();

      expect(await streamQueue.next, 'pause');

      receivePort.close();
    });

    test(
        '.resume(). Resumes all actors in actor system, receives message from actor when will it be resumed.',
        () async {
      var receivePort = ReceivePort();

      var streamQueue = StreamQueue(receivePort.asBroadcastStream());

      await actorSystem.actorOf('test_actor', TestActor_2(),
          data: {'feedbackPort': receivePort.sendPort});

      await actorSystem.pause();

      await actorSystem.resume();

      expect(await streamQueue.take(2), ['pause', 'resume']);

      receivePort.close();
    });

    test(
        '.kill(). Kills all actors in actor system, receives message from actor when will it be killed.',
        () async {
      var receivePort = ReceivePort();

      var streamQueue = StreamQueue(receivePort.asBroadcastStream());

      await actorSystem.actorOf('test_actor', TestActor_2(),
          data: {'feedbackPort': receivePort.sendPort});

      await actorSystem.kill();

      expect(await streamQueue.next, 'kill');

      receivePort.close();
    });

    test(
        '.dispose(). Disposes all actors in actor system, receives message from actor when will it be killed.',
        () async {
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
