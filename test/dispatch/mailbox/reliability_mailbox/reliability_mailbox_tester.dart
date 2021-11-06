import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:theater/src/dispatch.dart';

import '../mailbox_test_data.dart';
import '../mailbox_tester.dart';

class ReliabilityMailboxTester<T extends ReliableMailbox>
    extends MailboxTester<T> {
  Future<void> nextTest(MailboxTestData<T> data) async {
    var list = <int>[];

    for (var i = 0; i < 2; i++) {
      data.mailbox.sendPort.send(MailboxMessage(i, data.receivePort.sendPort));
    }

    await for (var message in data.mailbox.mailboxMessages) {
      list.add(message.data);

      data.mailbox.next();

      if (list.length == 2) {
        break;
      }
    }

    expect(list, [0, 1]);
  }

  Future<void> resendTest(MailboxTestData<T> data) async {
    var list = <int>[];

    data.mailbox.sendPort.send(MailboxMessage(100, data.receivePort.sendPort));

    await for (var message in data.mailbox.mailboxMessages) {
      list.add(message.data);

      data.mailbox.resend();

      if (list.length == 2) {
        break;
      }
    }

    expect(list, [100, 100]);
  }

  Future<void> mailboxMessagesTest(MailboxTestData<T> data) async {
    var list = <int>[];

    for (var i = 0; i < 5; i++) {
      data.mailbox.sendPort.send(MailboxMessage(i, data.receivePort.sendPort));
    }

    await for (var message in data.mailbox.mailboxMessages) {
      list.add(message.data);

      data.mailbox.next();

      if (list.length == 5) {
        break;
      }
    }

    expect(list, [0, 1, 2, 3, 4]);
  }

  Future<void> actorRoutingMessagesTest(MailboxTestData<T> data) async {
    var streamQueue = StreamQueue(data.mailbox.actorRoutingMessages);

    for (var i = 0; i < 5; i++) {
      data.mailbox.sendPort.send(ActorRoutingMessage(
          i.toString(), data.receivePort.sendPort, data.recipientPath));
    }

    expect(List.of((await streamQueue.take(5)).map((e) => e.data)),
        ['0', '1', '2', '3', '4']);
  }

  Future<void> systemRoutingMessagesTest(MailboxTestData<T> data) async {
    var streamQueue = StreamQueue(data.mailbox.systemRoutingMessages);

    for (var i = 0; i < 5; i++) {
      data.mailbox.sendPort.send(SystemRoutingMessage(
          i + 1, data.receivePort.sendPort, data.recipientPath));
    }

    expect(List.of((await streamQueue.take(5)).map((e) => e.data)),
        [1, 2, 3, 4, 5]);
  }

  @override
  Future<void> disposeTest(MailboxTestData<T> data) async {
    await super.disposeTest(data);
  }
}
