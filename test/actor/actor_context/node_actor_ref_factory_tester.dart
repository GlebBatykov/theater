import 'dart:isolate';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:theater/src/actor.dart';

import 'actor_context_test_data.dart';
import 'test_actor/test_untyped_actor_2.dart';

class NodeActorRefFactoryTester<T extends NodeActorRefFactory> {
  Future<void> actorOfTest(ActorContextTestData<T> data) async {
    var feedbackPort = ReceivePort();

    var streamQueue = StreamQueue(feedbackPort.asBroadcastStream());

    for (var i = 0; i < 5; i++) {
      await data.actorContext.actorOf(
          'test_child_' + i.toString(), TestUntypedActor_2(),
          data: {'feedbackPort': feedbackPort.sendPort});
    }

    expect(await streamQueue.take(5), List.generate(5, (index) => 'start'));
  }
}
