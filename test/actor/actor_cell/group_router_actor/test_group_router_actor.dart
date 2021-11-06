import 'dart:isolate';

import 'package:theater/src/actor.dart';
import 'package:theater/src/routing.dart';

class TestGroupRouterActor_1 extends GroupRouterActor {
  @override
  Future<void> onStart(context) async {
    SendPort feedbackPort = context.data['feedbackPort'];

    feedbackPort.send('start');
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

  @override
  GroupDeployementStrategy createDeployementStrategy() {
    return GroupDeployementStrategy(
        routingStrategy: GroupRoutingStrategy.broadcast, group: []);
  }
}
