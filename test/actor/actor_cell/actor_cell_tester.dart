import 'package:test/test.dart';
import 'package:theater/src/actor.dart';

import 'actor_cell_test_data.dart';

class ActorCellTester<T extends ActorCell> {
  Future<void> initializeTest(ActorCellTestData<T> data) async {
    await data.actorCell.initialize();

    expect(data.actorCell.isInitialized, true);
  }

  Future<void> startTest(ActorCellTestData<T> data) async {
    await data.actorCell.initialize();
    await data.actorCell.start();

    expect(await data.streamQueue.next, 'start');
    expect(data.actorCell.isInitialized, true);
    expect(data.actorCell.isStarted, true);
  }

  Future<void> restartTest(ActorCellTestData<T> data) async {
    await data.actorCell.initialize();
    await data.actorCell.start();
    await data.actorCell.restart();

    expect(await data.streamQueue.take(3), ['start', 'kill', 'start']);
    expect(data.actorCell.isInitialized, true);
    expect(data.actorCell.isStarted, true);
  }

  Future<void> pauseTest(ActorCellTestData<T> data) async {
    await data.actorCell.initialize();
    await data.actorCell.start();
    await data.actorCell.pause();

    expect(await data.streamQueue.take(2), ['start', 'pause']);
    expect(data.actorCell.isInitialized, true);
    expect(data.actorCell.isPaused, true);
  }

  Future<void> resumeTest(ActorCellTestData<T> data) async {
    await data.actorCell.initialize();
    await data.actorCell.start();
    await data.actorCell.pause();
    await data.actorCell.resume();

    expect(await data.streamQueue.take(3), ['start', 'pause', 'resume']);
    expect(data.actorCell.isInitialized, true);
    expect(data.actorCell.isStarted, true);
  }

  Future<void> equalOperatorTest(ActorCellTestData<T> data) async {
    expect(data.actorCell == data.actorCell, true);
  }

  Future<void> killTest(ActorCellTestData<T> data) async {
    await data.actorCell.initialize();
    await data.actorCell.kill();

    expect(await data.streamQueue.take(1), ['kill']);
  }

  Future<void> disposeTest(ActorCellTestData<T> data) async {
    await data.actorCell.dispose();

    expect(data.actorCell.isDisposed, true);
  }
}
