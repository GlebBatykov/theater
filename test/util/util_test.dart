import 'dart:async';

import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:theater/src/util.dart';

void main() {
  group('util', () {
    group('cancellation_token', () {
      late CancellationToken cancellationToken;

      setUp(() {
        cancellationToken = CancellationToken();
      });

      tearDown(() async {
        if (!cancellationToken.isDisposed) {
          if (!cancellationToken.isCanceled) {
            cancellationToken.cancel();
          }

          await cancellationToken.dispose();
        }
      });

      test('.addOnCancelListener(). Subscribes to onCancel event, gets event.',
          () async {
        var streamController = StreamController<String>();

        cancellationToken.addOnCancelListener(() {
          streamController.sink.add('cancel');
        });

        cancellationToken.cancel();

        var event = await streamController.stream.first;

        expect(event, 'cancel');
      });

      test('.cancel(). Sends cancel event to all onCancel subscribers.', () {
        cancellationToken.cancel();

        expect(cancellationToken.isCanceled, true);
      });

      group('ref.', () {
        test('Gets ref to token and check is token canceled.', () async {
          var ref = cancellationToken.ref;

          var isCanceled = await ref.isCanceled();

          expect(isCanceled, false);
        });

        test('Gets ref to token and cancel token using ref.', () async {
          var ref = cancellationToken.ref;

          await ref.cancel();

          await Future.delayed(Duration(milliseconds: 10), () async {
            expect(cancellationToken.isCanceled, true);
          });
        });
      });

      test('.dipose(). ', () async {
        await cancellationToken.dispose();

        expect(cancellationToken.isDisposed, true);
      });
    });

    group('scheduler', () {
      group('repeatedly_action_token', () {
        late RepeatedlyActionToken actionToken;

        setUp(() {
          actionToken = RepeatedlyActionToken();
        });

        tearDown(() async {
          if (!actionToken.isDisposed) {
            await actionToken.dispose();
          }
        });

        test('.stop(). ', () async {
          actionToken.stop();

          expect(actionToken.isStoped, true);
        });

        test('.resume(). ', () async {
          actionToken.stop();
          actionToken.resume();

          expect(actionToken.isRunning, true);
        });

        test('.dispose(). ', () async {
          await actionToken.dispose();

          expect(actionToken.isDisposed, true);
        });
      });

      group('one_shot_action_token', () {
        late OneShotActionToken actionToken;

        setUp(() {
          actionToken = OneShotActionToken();
        });

        tearDown(() async {
          if (!actionToken.isDisposed) {
            await actionToken.dispose();
          }
        });

        test('.call(). ', () async {
          var streamController = StreamController<int>();

          actionToken.addOnCallListener(() {
            streamController.sink.add(12);
          });

          actionToken.call();

          expect(await streamController.stream.first, 12);
        });

        test('.dispose(). ', () async {
          await actionToken.dispose();

          expect(actionToken.isDisposed, true);
        });
      });

      group('.scheduleActionRepeatedly().', () {
        late Scheduler scheduler;

        late RepeatedlyActionToken actionToken;

        setUp(() {
          scheduler = Scheduler();

          actionToken = RepeatedlyActionToken();
        });

        tearDown(() async {
          if (!actionToken.isDisposed) {
            if (actionToken.isRunning) {
              actionToken.stop();
            }

            await actionToken.dispose();
          }
        });

        test(
            'Without initial delay. Creates scheduled action repeatedly without initial delay, receives 5 messages from action.',
            () async {
          var counter = 0;

          var list = <int>[];

          var streamController = StreamController<int>();

          var stopwatch = Stopwatch()..start();

          scheduler.scheduleRepeatedlyAction(
              interval: Duration(milliseconds: 20),
              action: (RepeatedlyActionContext actionContext) async {
                streamController.sink.add(++counter);
              },
              actionToken: actionToken);

          await for (var event in streamController.stream) {
            list.add(event);

            if (list.length == 5) {
              actionToken.stop();
              break;
            }
          }

          stopwatch.stop();

          expect(list, [1, 2, 3, 4, 5]);
          expect(stopwatch.elapsedMilliseconds, lessThan(200));
        });

        test(
            'With initial delay. Creates scheduled action repeatedly with initial delay, receives 5 messages from action.',
            () async {
          var counter = 0;

          var list = <int>[];

          var streamController = StreamController<int>();

          var stopwatch = Stopwatch()..start();

          scheduler.scheduleRepeatedlyAction(
              interval: Duration(milliseconds: 50),
              action: (RepeatedlyActionContext actionContext) async {
                streamController.sink.add(++counter);
              },
              actionToken: actionToken);

          await for (var event in streamController.stream) {
            list.add(event);

            if (list.length == 5) {
              actionToken.stop();
              break;
            }
          }

          stopwatch.stop();

          expect(list, [1, 2, 3, 4, 5]);
          expect(stopwatch.elapsedMilliseconds, inExclusiveRange(200, 400));
        });
      });
    });

    group('repeatedly_action_context', () {
      test('.number. ', () async {});
    });

    group('one_shot_action_context', () {
      test('.number. ', () async {});
    });
  }, timeout: Timeout(Duration(seconds: 1)));
}
