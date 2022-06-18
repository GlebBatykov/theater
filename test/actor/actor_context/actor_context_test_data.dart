import 'dart:isolate';

import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';
import 'package:theater/src/isolate.dart';

class ActorContextTestData<T extends ActorContext> {
  final T actorContext;

  final UnreliableMailbox mailbox;

  final UnreliableMailbox? parentMailbox;

  final ReceivePort? isolateReceivePort;

  final IsolateContext isolateContext;

  final ReceivePort supervisorMessagePort;

  final ReceivePort supervisorErrorPort;

  final ReceivePort actorSystemSendPort;

  final ReceivePort? feedbackPort;

  ActorContextTestData(
      this.actorContext,
      this.mailbox,
      this.isolateContext,
      this.supervisorMessagePort,
      this.supervisorErrorPort,
      this.actorSystemSendPort,
      {this.parentMailbox,
      this.feedbackPort,
      this.isolateReceivePort});
}
