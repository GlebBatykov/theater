import 'dart:async';
import 'dart:isolate';

import 'package:async/async.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:theater/src/dispatch.dart';
import 'package:theater/src/routing.dart';
import 'package:theater/src/util.dart';

import 'mailbox/mailbox_test_data.dart';
import 'mailbox/priority_reliability_mailbox/priority_reliability_mailbox_tester.dart';
import 'mailbox/priority_reliability_mailbox/test_priority_generator.dart';
import 'mailbox/reliability_mailbox/reliability_mailbox_tester.dart';
import 'mailbox/unreliability_mailbox/unreliability_mailbox_tester.dart';

void main() {
  group('message_routing', () {
    group('message_subscription', () {
      late ReceivePort receivePort;

      late MessageSubscription subscription;

      setUp(() {
        receivePort = ReceivePort();

        subscription = MessageSubscription(receivePort);
      });

      tearDown(() {
        receivePort.close();
      });

      test(
          '.listen(). Sends result to receive port which the subscription using and receive him from .listen() method.',
          () async {
        var result = DeliveredSuccessfullyResult();

        var streamController = StreamController<MessageResponse>();

        subscription.onResponse((response) {
          streamController.sink.add(response);
        });

        receivePort.sendPort.send(result);

        var response = await streamController.stream.first;

        expect(response, isA<DeliveredSuccessfullyResult>());
        expect(subscription.isCanceled, true);

        await streamController.close();
      });

      test(
          '.cancel(). Uses .cancel() method for cancel subscription and checks subscription status.',
          () async {
        subscription.cancel();

        expect(subscription.isCanceled, true);
      });

      test(
          '.stream. Sends result to receive port which the subscription using and uses subscription getter .stream for receive him, checks subscription status.',
          () async {
        var result = MessageResult(data: 'Hello, test world!');

        receivePort.sendPort.send(result);

        var first = await subscription.stream
            .where((element) => element is MessageResult)
            .cast<MessageResult>()
            .first;

        expect(first.data, 'Hello, test world!');
        expect(subscription.isCanceled, true);
      });

      test('.asMultipleSubscription. ', () async {
        var result = MessageResult(data: 'Hello, test world!');

        subscription = subscription.asMultipleSubscription();

        for (var i = 0; i < 5; i++) {
          receivePort.sendPort.send(result);
        }

        var streamQueue = StreamQueue(subscription.stream);

        expect(
            List.of((await streamQueue.take(5))
                .cast<MessageResult>()
                .map((e) => e.data)),
            List.generate(5, (index) => 'Hello, test world!'));
        expect(subscription.isCanceled, false);
      });
    });

    group('mailbox', () {
      late ReceivePort receivePort;

      var path = ActorPath('test_system', 'test', 0);

      var recipientPath = path.createChild('test');

      setUp(() {
        receivePort = ReceivePort();
      });

      tearDown(() {
        receivePort.close();
      });

      group('unreliability_mailbox', () {
        late UnreliableMailbox mailbox;

        late MailboxTestData<UnreliableMailbox> data;

        setUp(() {
          mailbox = UnreliableMailbox(path);

          data = MailboxTestData(mailbox, receivePort, path, recipientPath);
        });

        tearDown(() {
          if (!mailbox.isDisposed) {
            mailbox.dispose();
          }
        });

        test('.mailboxMessages. Sends messages to mailbox and receive their.',
            () async {
          await UnreliableMailboxTester().mailboxMessagesTest(data);
        });

        test(
            '.actorRoutingMessages. Sends messages to mailbox and receive their.',
            () async {
          await UnreliableMailboxTester().actorRoutingMessagesTest(data);
        });

        test(
            '.systemRoutingMessages. Sends messages to mailbox and receive their.',
            () async {
          await UnreliableMailboxTester().systemRoutingMessagesTest(data);
        });

        test('.dispose(). Disposes mailbox and checks him status.', () async {
          await UnreliableMailboxTester().disposeTest(data);
        });
      });

      group('reliability_mailbox', () {
        late ReliableMailbox mailbox;

        late MailboxTestData<ReliableMailbox> data;

        setUp(() {
          mailbox = ReliableMailbox(path, HandlingType.asynchronously);

          data = MailboxTestData(mailbox, receivePort, path, recipientPath);
        });

        tearDown(() {
          if (!mailbox.isDisposed) {
            mailbox.dispose();
          }
        });

        test(
            '.next(). Sends two message and receive their. Uses method .next() after receving first message.',
            () async {
          await ReliabilityMailboxTester().nextTest(data);
        });

        test(
            '.resend(). Sends message, receive their and uses method .resend() to get it again.',
            () async {
          await ReliabilityMailboxTester().resendTest(data);
        });

        test('.mailboxMessages. Sends messages to mailbox and receive their.',
            () async {
          await ReliabilityMailboxTester().mailboxMessagesTest(data);
        });

        test(
            '.actorRoutingMessages. Sends messages to mailbox and receive their.',
            () async {
          await ReliabilityMailboxTester().actorRoutingMessagesTest(data);
        });

        test(
            '.systemRoutingMessages. Sends messages to mailbox and receive their.',
            () async {
          await ReliabilityMailboxTester().systemRoutingMessagesTest(data);
        });

        test('.dispose(). Disposes mailbox and checks him status.', () async {
          await ReliabilityMailboxTester().disposeTest(data);
        });
      });

      group('priority_reliability_mailbox', () {
        late PriorityReliableMailbox mailbox;

        late MailboxTestData<PriorityReliableMailbox> data;

        setUp(() {
          mailbox = PriorityReliableMailbox(path, HandlingType.asynchronously,
              priorityGenerator: TestPriorityGenerator_1());

          data = MailboxTestData(mailbox, receivePort, path, recipientPath);
        });

        tearDown(() {
          if (!mailbox.isDisposed) {
            mailbox.dispose();
          }
        });

        test(
            '.next(). Sends two message and receive their. Uses method .next() after receving first message.',
            () async {
          await PriorityReliableMailboxTester().nextTest(data);
        });

        test('.mailboxMessages. Sends messages to mailbox and receive their.',
            () async {
          await PriorityReliableMailboxTester().mailboxMessagesTest(data);
        });

        test(
            '.actorRoutingMessages. Sends messages to mailbox and receive their.',
            () async {
          await PriorityReliableMailboxTester().actorRoutingMessagesTest(data);
        });

        test(
            '.systemRoutingMessages. Sends messages to mailbox and receive their.',
            () async {
          await PriorityReliableMailboxTester().systemRoutingMessagesTest(data);
        });

        test(
            'priority. Creates priority generator, sends messages to mailbox and receive their according to priority.',
            () async {
          await PriorityReliableMailboxTester().priorityTest(data);
        });

        test('.dispose(). Disposes mailbox and checks him status.', () async {
          await PriorityReliableMailboxTester().disposeTest(data);
        });
      });
    });

    group('ref', () {
      group('scheduler_action_token_ref', () {
        late ReceivePort receivePort;

        late RepeatedlyActionTokenRef actionTokenRef;

        setUp(() {
          receivePort = ReceivePort();

          actionTokenRef = RepeatedlyActionTokenRef(receivePort.sendPort);
        });

        tearDown(() {
          receivePort.close();
        });

        group('repeatedly_action_token_ref', () {
          test('.stop(). ', () async {
            actionTokenRef.stop();

            expect(await receivePort.first, isA<RepeatedlyActionTokenStop>());
          });

          test('.resume(). ', () async {
            actionTokenRef.resume();

            expect(await receivePort.first, isA<RepeatedlyActionTokenResume>());
          });

          test('.getStatus(). ', () async {
            unawaited(actionTokenRef.getStatus());

            expect(
                await receivePort.first, isA<RepeatedlyActionTokenGetStatus>());
          });

          test('.isRunning(). ', () async {
            unawaited(actionTokenRef.isRunning());

            expect(
                await receivePort.first, isA<RepeatedlyActionTokenGetStatus>());
          });

          test('.isStoped(). ', () async {
            unawaited(actionTokenRef.isStoped());

            expect(
                await receivePort.first, isA<RepeatedlyActionTokenGetStatus>());
          });
        });

        group('one_shot_action_token_ref', () {
          late ReceivePort receivePort;

          late OneShotActionTokenRef actionTokenRef;

          setUp(() {
            receivePort = ReceivePort();

            actionTokenRef = OneShotActionTokenRef(receivePort.sendPort);
          });

          tearDown(() {
            receivePort.close();
          });

          test('.call(). ', () async {
            actionTokenRef.call();

            expect(await receivePort.first, isA<OneShotActionTokenCall>());
          });
        });
      });
    });
  }, timeout: Timeout(Duration(seconds: 1)));
}
