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

      tearDown(() {
        cancellationToken.cancel();
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

      test('.cancel(). Send cancel event to all onCancel subscribers.', () {
        cancellationToken.cancel();

        expect(cancellationToken.isCanceled, true);
      });
    });

    group('scheduler', () {
      late Scheduler scheduler;

      late CancellationToken cancellationToken;

      setUp(() {
        scheduler = Scheduler();

        cancellationToken = CancellationToken();
      });

      tearDown(() {
        cancellationToken.cancel();
      });

      group('.scheduleActionRepeatedly().', () {
        test(
            'Without initial delay. Creates scheduled action repeatedly without initial delay, receives 5 messages from action.',
            () async {
          var counter = 0;

          var list = <int>[];

          var streamController = StreamController<int>();

          var stopwatch = Stopwatch()..start();

          scheduler.scheduleActionRepeatedly(
              interval: Duration(milliseconds: 20),
              action: () async {
                streamController.sink.add(++counter);
              },
              cancellationToken: cancellationToken);

          await for (var event in streamController.stream) {
            list.add(event);

            if (list.length == 5) {
              cancellationToken.cancel();
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

          scheduler.scheduleActionRepeatedly(
              interval: Duration(milliseconds: 50),
              action: () async {
                streamController.sink.add(++counter);
              },
              cancellationToken: cancellationToken);

          await for (var event in streamController.stream) {
            list.add(event);

            if (list.length == 5) {
              cancellationToken.cancel();
              break;
            }
          }

          stopwatch.stop();

          expect(list, [1, 2, 3, 4, 5]);
          expect(stopwatch.elapsedMilliseconds, inExclusiveRange(200, 400));
        });
      });
    });
  }, timeout: Timeout(Duration(seconds: 1)));
}
