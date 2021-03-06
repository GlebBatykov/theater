import 'dart:io';
import 'dart:isolate';

import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';

class TestWorkerActor_1 extends WorkerActor {
  @override
  Future<void> onStart(context) async {
    var feedbackPort = context.store.get<SendPort>('feedbackPort');

    feedbackPort.send('start');

    context.receive<String>((message) async {
      sleep(Duration(milliseconds: 100));

      return MessageResult(data: message);
    });
  }

  @override
  Future<void> onPause(context) async {
    var feedbackPort = context.store.get<SendPort>('feedbackPort');

    feedbackPort.send('pause');
  }

  @override
  Future<void> onResume(context) async {
    var feedbackPort = context.store.get<SendPort>('feedbackPort');

    feedbackPort.send('resume');
  }

  @override
  Future<void> onKill(context) async {
    var feedbackPort = context.store.get<SendPort>('feedbackPort');

    feedbackPort.send('kill');
  }
}
