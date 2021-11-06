import 'dart:isolate';

import 'package:theater/src/actor.dart';

class TestActor_2 extends UntypedActor {
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
