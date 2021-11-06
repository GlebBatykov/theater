import 'package:test/test.dart';
import 'package:theater/src/dispatch.dart';

import '../mailbox_test_data.dart';
import '../reliability_mailbox/reliability_mailbox_tester.dart';

class PriorityReliableMailboxTester<T extends PriorityReliableMailbox>
    extends ReliabilityMailboxTester<T> {
  Future<void> priorityTest(MailboxTestData<T> data) async {
    var list = [];

    var testList = ['1', 1.21, 22, 54, 'hello'];

    for (var i = 0; i < testList.length; i++) {
      data.mailbox.sendPort
          .send(MailboxMessage(testList[i], data.receivePort.sendPort));
    }

    await for (var message in data.mailbox.mailboxMessages) {
      list.add(message.data);

      await Future.delayed(Duration(milliseconds: 20), () {
        data.mailbox.next();
      });

      if (list.length == 5) {
        break;
      }
    }

    expect(list, ['1', 'hello', 22, 54, 1.21]);
  }

  @override
  Future<void> nextTest(MailboxTestData<T> data) async {
    await super.nextTest(data);
  }

  @override
  Future<void> resendTest(MailboxTestData<T> data) async {
    await super.resendTest(data);
  }

  @override
  Future<void> mailboxMessagesTest(MailboxTestData<T> data) async {
    await super.mailboxMessagesTest(data);
  }

  @override
  Future<void> actorRoutingMessagesTest(MailboxTestData<T> data) async {
    await super.actorRoutingMessagesTest(data);
  }

  @override
  Future<void> systemRoutingMessagesTest(MailboxTestData<T> data) async {
    await super.systemRoutingMessagesTest(data);
  }

  @override
  Future<void> disposeTest(MailboxTestData<T> data) async {
    await super.disposeTest(data);
  }
}
