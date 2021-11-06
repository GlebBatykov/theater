import 'dart:isolate';

import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';

class TestActor_1 extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    SendPort feedbackPort = context.data['feedbackPort'];

    feedbackPort.send('start');

    context.receive<String>((message) async {
      return MessageResult(data: message);
    });
  }

  @override
  Future<void> onPause(context) async {
    SendPort feedbackPort = context.data['feedbackPort'];

    feedbackPort.send('pause');
  }

  @override
  Future<void> onResume(context) async {
    SendPort feedbackPort = context.data['feedbackPort'];

    feedbackPort.send('resume');
  }

  @override
  Future<void> onKill(context) async {
    SendPort feedbackPort = context.data['feedbackPort'];

    feedbackPort.send('kill');
  }
}
