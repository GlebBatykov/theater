import 'dart:isolate';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';
import 'package:theater/src/isolate.dart';
import 'package:theater/src/logging.dart';
import 'package:theater/src/routing.dart';

import 'isolate/test_actor_1.dart';

void main() {
  group('isolate', () {
    group('isolate_supervisor', () {
      final loggingProperties =
          ActorLoggingProperties(loggerFactory: TheaterLoggerFactory());

      var actorSystemSendPort = ReceivePort();

      var actor = TestActor_1();

      var parentPath = ActorPath('test_system', 'user', 1);

      var parentMailbox = UnreliableMailbox(parentPath);

      var parentRef = LocalActorRef(parentPath, parentMailbox.sendPort);

      var actorPath = parentPath.createChild('test_actor');

      var actorMailbox =
          actor.createMailboxFactory().create(MailboxProperties(actorPath));

      var actorRef = LocalActorRef(actorPath, actorMailbox.sendPort);

      late ReceivePort receivePort;

      late Stream stream;

      late StreamQueue streamQueue;

      late IsolateSupervisor supervisor;

      setUp(() async {
        receivePort = ReceivePort();

        stream = receivePort.asBroadcastStream();

        streamQueue = StreamQueue(stream);

        supervisor = IsolateSupervisor(
            actor,
            UntypedActorProperties(
                actorRef: actorRef,
                supervisorStrategy: actor.createSupervisorStrategy(),
                parentRef: parentRef,
                handlingType: HandlingType.asynchronously,
                mailboxType: actorMailbox.type,
                actorSystemSendPort: actorSystemSendPort.sendPort,
                loggingProperties: loggingProperties,
                data: {'feedbackPort': receivePort.sendPort}),
            UntypedActorIsolateHandlerFactory(),
            UntypedActorContextBuilder());
      });

      tearDown(() async {
        receivePort.close();

        await streamQueue.cancel();

        if (!supervisor.isDisposed) {
          await supervisor.dispose();
        }
      });

      tearDownAll(() async {
        await parentMailbox.dispose();
        await actorMailbox.dispose();
        actorSystemSendPort.close();
      });

      test(
          '.initialize(). Initializes supervisor and checks supervisor status.',
          () async {
        await supervisor.initialize();

        expect(supervisor.isInitialized, true);
      });

      test(
          '.start(). Starts supervisor with, receives message from actor and checks supervisor status.',
          () async {
        await supervisor.initialize();
        await supervisor.start();

        expect(supervisor.isInitialized, true);
        expect(supervisor.isStarted, true);
        await expectLater(await streamQueue.next, 'start');
      });

      test(
          '.pause(). Pauses supervisor, receives messages from actor and checks supervisor status.',
          () async {
        await supervisor.initialize();
        await supervisor.start();
        await supervisor.pause();

        expect(supervisor.isInitialized, true);
        expect(supervisor.isStarted, true);
        expect(supervisor.isPaused, true);
        await expectLater(await streamQueue.take(2), ['start', 'pause']);
      });

      test(
          '.resume(). Resumes supervisor, receives messages from actor and checks supervisor status.',
          () async {
        await supervisor.initialize();
        await supervisor.start();
        await supervisor.pause();
        await supervisor.resume();

        expect(supervisor.isInitialized, true);
        expect(supervisor.isStarted, true);
        expect(supervisor.isPaused, false);
        await expectLater(
            await streamQueue.take(3), ['start', 'pause', 'resume']);
      });

      test(
          '.kill(). Kills supervisor, receives messages from actor and checks supervisor status.',
          () async {
        await supervisor.initialize();
        await supervisor.kill();

        expect(supervisor.isInitialized, false);
        await expectLater(await streamQueue.next, 'kill');
      });

      test(
          '.dispose(). Disposes supervisor, receives messages from actor and checks supervisor status.',
          () async {
        await supervisor.initialize();
        await supervisor.start();
        await supervisor.dispose();

        expect(supervisor.isInitialized, false);
        expect(supervisor.isStarted, false);
        expect(supervisor.isDisposed, true);
        expect(await streamQueue.take(2), ['start', 'kill']);
      });

      test('.send(). Sends message to actor and receives message from actor.',
          () async {
        await supervisor.initialize();
        await supervisor.start();

        supervisor.send(ActorMailboxMessage('Hello, test world!',
            feedbackPort: receivePort.sendPort));

        expect(supervisor.isInitialized, true);
        expect(supervisor.isStarted, true);

        var list = await streamQueue.take(2);

        expect(list[0], 'start');
        expect(list[1], isA<MessageResult>());
        expect((list[1] as MessageResult).data, 'Hello, test world!');
      });
    });
  }, timeout: Timeout(Duration(seconds: 1)));
}
