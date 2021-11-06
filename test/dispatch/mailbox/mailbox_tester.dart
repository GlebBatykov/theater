import 'package:test/test.dart';
import 'package:theater/src/dispatch.dart';

import 'mailbox_test_data.dart';

class MailboxTester<T extends Mailbox> {
  Future<void> disposeTest(MailboxTestData<T> data) async {
    await data.mailbox.dispose();

    expect(data.mailbox.isDisposed, true);
  }
}
