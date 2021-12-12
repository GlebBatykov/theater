import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:theater/src/dispatch.dart';

import '../mailbox_test_data.dart';
import '../mailbox_tester.dart';

class UnreliableMailboxTester<T extends UnreliableMailbox>
    extends MailboxTester<T> {
  Future<void> mailboxMessagesTest(MailboxTestData<T> data) async {
    var streamQueue = StreamQueue(data.mailbox.mailboxMessages);

    for (var i = 0; i < 5; i++) {
      data.mailbox.sendPort
          .send(MailboxMessage(i, feedbackPort: data.receivePort.sendPort));
    }

    expect(List.of((await streamQueue.take(5)).map((e) => e.data)),
        [0, 1, 2, 3, 4]);
  }

  Future<void> actorRoutingMessagesTest(MailboxTestData<T> data) async {
    var streamQueue = StreamQueue(data.mailbox.actorRoutingMessages);

    for (var i = 0; i < 5; i++) {
      data.mailbox.sendPort.send(ActorRoutingMessage(
        i + 1,
        data.recipientPath,
        feedbackPort: data.receivePort.sendPort,
      ));
    }

    expect(List.of((await streamQueue.take(5)).map((e) => e.data)),
        [1, 2, 3, 4, 5]);
  }

  Future<void> systemRoutingMessagesTest(MailboxTestData<T> data) async {
    var streamQueue = StreamQueue(data.mailbox.systemRoutingMessages);

    for (var i = 0; i < 5; i++) {
      data.mailbox.sendPort.send(SystemRoutingMessage(
        i.toString(),
        data.recipientPath,
        feedbackPort: data.receivePort.sendPort,
      ));
    }

    expect(List.of((await streamQueue.take(5)).map((e) => e.data)),
        ['0', '1', '2', '3', '4']);
  }

  @override
  Future<void> disposeTest(MailboxTestData<T> data) async {
    await super.disposeTest(data);
  }
}
