import 'dart:isolate';

import 'package:theater/src/actor.dart';
import 'package:theater/src/remote.dart';

class TestRootActor_1 extends RootActor {
  TestRootActor_1() : super(RemoteTransportConfiguration());

  @override
  Future<void> onStart(context) async {
    var feedbackPort = context.store.get<SendPort>('feedbackPort');

    feedbackPort.send('start');
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
