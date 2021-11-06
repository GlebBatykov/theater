import 'dart:isolate';

import 'package:theater/src/dispatch.dart';
import 'package:theater/src/routing.dart';

class MailboxTestData<T extends Mailbox> {
  final ReceivePort receivePort;

  final ActorPath path;

  final ActorPath recipientPath;

  final T mailbox;

  MailboxTestData(
      this.mailbox, this.receivePort, this.path, this.recipientPath);
}
