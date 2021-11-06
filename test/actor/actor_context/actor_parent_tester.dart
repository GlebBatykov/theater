import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:theater/src/actor.dart';

import 'actor_context_test_data.dart';

class ActorParentTester<T extends ActorParent> {
  Future<void> killChildrenTest(ActorContextTestData<T> data) async {
    var streamQueue = StreamQueue(data.feedbackPort!.asBroadcastStream());

    await data.actorContext.killChildren();

    expect(await streamQueue.take(10),
        List.generate(10, (index) => index <= 4 ? 'start' : 'kill'));
  }

  Future<void> pauseChildrenTest(ActorContextTestData<T> data) async {
    var streamQueue = StreamQueue(data.feedbackPort!.asBroadcastStream());

    await data.actorContext.pauseChildren();

    expect(await streamQueue.take(10),
        List.generate(10, (index) => index <= 4 ? 'start' : 'pause'));
  }

  Future<void> resumeChildrenTest(ActorContextTestData<T> data) async {
    var streamQueue = StreamQueue(data.feedbackPort!.asBroadcastStream());

    await data.actorContext.pauseChildren();

    await data.actorContext.resumeChildren();

    expect(
        await streamQueue.take(15),
        List.generate(
            15,
            (index) => index <= 4
                ? 'start'
                : index <= 9
                    ? 'pause'
                    : 'resume'));
  }

  Future<void> restartChildrenTest(ActorContextTestData<T> data) async {
    var streamQueue = StreamQueue(data.feedbackPort!.asBroadcastStream());

    await data.actorContext.restartChildren();

    expect(
        await streamQueue.take(15),
        List.generate(
            15,
            (index) => index <= 4
                ? 'start'
                : index.isOdd
                    ? 'kill'
                    : 'start'));
  }
}
