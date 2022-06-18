import 'dart:isolate';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';
import 'package:theater/src/logging.dart';
import 'package:theater/src/routing.dart';

import 'actor_cell/actor_cell_test_data.dart';
import 'actor_cell/group_router_actor/group_router_actor_cell_tester.dart';
import 'actor_cell/group_router_actor/test_group_router_actor.dart';
import 'actor_cell/pool_router_actor/pool_router_actor_cell_tester.dart';
import 'actor_cell/pool_router_actor/test_pool_router_actor.dart';
import 'actor_cell/root_actor/root_actor_cell_tester.dart';
import 'actor_cell/root_actor/test_root_actor.dart';
import 'actor_cell/untyped_actor/test_untyped_actor.dart';
import 'actor_cell/untyped_actor/untyped_actor_cell_tester.dart';
import 'actor_cell/worker_actor/test_worker_actor.dart';
import 'actor_cell/worker_actor/worker_actor_cell_tester.dart';

void main() {
  group('actor_cell', () {
    final loggingProperties =
        LoggingProperties(loggerFactory: TheaterLoggerFactory());

    group('root_actor_cell', () {
      var actorSystemSendPort = ReceivePort();

      var path = ActorPath('test_system', 'test', 0);

      late ReceivePort receivePort;

      late StreamQueue streamQueue;

      late RootActorCell actorCell;

      late ActorCellTestData<RootActorCell> data;

      setUp(() {
        receivePort = ReceivePort();

        streamQueue = StreamQueue(receivePort.asBroadcastStream());

        actorCell = RootActorCell(path, TestRootActor_1(),
            actorSystemSendPort.sendPort, loggingProperties,
            data: {'feedbackPort': receivePort.sendPort});

        data = ActorCellTestData(actorCell, receivePort, streamQueue);
      });

      tearDown(() {
        receivePort.close();

        if (!actorCell.isDisposed) {
          actorCell.dispose();
        }
      });

      tearDownAll(() {
        actorSystemSendPort.close();
      });

      test('.initialize(). Initialize actor cell and check status.', () async {
        await RootActorCellTester().initializeTest(data);
      });

      test(
          '.start(). Start actor cell, receive message from cell and check status.',
          () async {
        await RootActorCellTester().startTest(data);
      });

      test(
          '.restart(). Restart actor cell, receive messages from cell and check status.',
          () async {
        await RootActorCellTester().restartTest(data);
      });

      test(
          '.pause(). Pause actor cell, receive messsages from cell and check status.',
          () async {
        await RootActorCellTester().pauseTest(data);
      });

      test(
          '.resume(). Resume actor cell, receive messages from cell and check status.',
          () async {
        await RootActorCellTester().resumeTest(data);
      });

      test('.kill(). Kill actor cell, receive messsage from cell.', () async {
        await RootActorCellTester().killTest(data);
      });

      test('equal operator. Compare cells.', () async {
        await RootActorCellTester().equalOperatorTest(data);
      });

      test('.dispose(). Dispose actor cell and check status.', () async {
        await RootActorCellTester().disposeTest(data);
      });
    });

    group('untyped_actor_cell', () {
      var actorSystemSendPort = ReceivePort();

      var parentPath = ActorPath('test_system', 'test', 0);

      var path = parentPath.createChild('test_child');

      late ReceivePort parentReceivePort;

      late LocalActorRef parentRef;

      late ReceivePort receivePort;

      late StreamQueue streamQueue;

      late UntypedActorCell actorCell;

      late ActorCellTestData<UntypedActorCell> data;

      setUp(() {
        parentReceivePort = ReceivePort();

        parentRef = LocalActorRef(path, parentReceivePort.sendPort);

        receivePort = ReceivePort();

        streamQueue = StreamQueue(receivePort.asBroadcastStream());

        actorCell = UntypedActorCell(path, TestUntypedActor_1(), parentRef,
            actorSystemSendPort.sendPort, loggingProperties,
            data: {'feedbackPort': receivePort.sendPort});

        data = ActorCellTestData(actorCell, receivePort, streamQueue);
      });

      tearDown(() {
        parentReceivePort.close();

        receivePort.close();

        if (!actorCell.isDisposed) {
          actorCell.dispose();
        }
      });

      tearDownAll(() {
        actorSystemSendPort.close();
      });

      test('.initialize(). Initialize actor cell and check status.', () async {
        await UntypedActorCellTester().initializeTest(data);
      });

      test(
          '.start(). Start actor cell, receive message from cell and check status.',
          () async {
        await UntypedActorCellTester().startTest(data);
      });

      test(
          '.restart(). Restart actor cell, receive messages from cell and check status.',
          () async {
        await UntypedActorCellTester().restartTest(data);
      });

      test(
          '.pause(). Pause actor cell, receive messsages from cell and check status.',
          () async {
        await UntypedActorCellTester().pauseTest(data);
      });

      test(
          '.resume(). Resume actor cell, receive messages from cell and check status.',
          () async {
        await UntypedActorCellTester().resumeTest(data);
      });

      test('.kill(). Kill actor cell, receive messsage from cell.', () async {
        await UntypedActorCellTester().killTest(data);
      });

      test('equal operator. Compare cells.', () async {
        await UntypedActorCellTester().equalOperatorTest(data);
      });

      test('.dispose(). Dispose actor cell and check status.', () async {
        await UntypedActorCellTester().disposeTest(data);
      });
    });

    group('group_router_actor_cell', () {
      var actorSystemSendPort = ReceivePort();

      var parentPath = ActorPath('test_system', 'test', 0);

      var path = parentPath.createChild('test_child');

      late ReceivePort parentReceivePort;

      late LocalActorRef parentRef;

      late ReceivePort receivePort;

      late StreamQueue streamQueue;

      late GroupRouterActorCell actorCell;

      late ActorCellTestData<GroupRouterActorCell> data;

      setUp(() {
        parentReceivePort = ReceivePort();

        parentRef = LocalActorRef(path, parentReceivePort.sendPort);

        receivePort = ReceivePort();

        streamQueue = StreamQueue(receivePort.asBroadcastStream());

        actorCell = GroupRouterActorCell(path, TestGroupRouterActor_1(),
            parentRef, actorSystemSendPort.sendPort, loggingProperties,
            data: {'feedbackPort': receivePort.sendPort});

        data = ActorCellTestData(actorCell, receivePort, streamQueue);
      });

      tearDown(() {
        parentReceivePort.close();

        receivePort.close();

        if (!actorCell.isDisposed) {
          actorCell.dispose();
        }
      });

      tearDownAll(() {
        actorSystemSendPort.close();
      });

      test('.initialize(). Initialize actor cell and check status.', () async {
        await GroupRouterActorCellTester().initializeTest(data);
      });

      test(
          '.start(). Start actor cell, receive message from cell and check status.',
          () async {
        await GroupRouterActorCellTester().startTest(data);
      });

      test(
          '.restart(). Restart actor cell, receive messages from cell and check status.',
          () async {
        await GroupRouterActorCellTester().restartTest(data);
      });

      test(
          '.pause(). Pause actor cell, receive messsages from cell and check status.',
          () async {
        await GroupRouterActorCellTester().pauseTest(data);
      });

      test(
          '.resume(). Resume actor cell, receive messages from cell and check status.',
          () async {
        await GroupRouterActorCellTester().resumeTest(data);
      });

      test('.kill(). Kill actor cell, receive messsage from cell.', () async {
        await GroupRouterActorCellTester().killTest(data);
      });

      test('equal operator. Compare cells.', () async {
        await GroupRouterActorCellTester().equalOperatorTest(data);
      });

      test('.dispose(). Dispose actor cell and check status.', () async {
        await GroupRouterActorCellTester().disposeTest(data);
      });
    });

    group('pool_router_actor_cell', () {
      var actorSystemSendPort = ReceivePort();

      var parentPath = ActorPath('test_system', 'test', 0);

      var path = parentPath.createChild('test_child');

      late ReceivePort parentReceivePort;

      late LocalActorRef parentRef;

      late ReceivePort receivePort;

      late StreamQueue streamQueue;

      late PoolRouterActorCell actorCell;

      late ActorCellTestData<PoolRouterActorCell> data;

      setUp(() {
        parentReceivePort = ReceivePort();

        parentRef = LocalActorRef(path, parentReceivePort.sendPort);

        receivePort = ReceivePort();

        streamQueue = StreamQueue(receivePort.asBroadcastStream());

        actorCell = PoolRouterActorCell(path, TestPoolRouterActor_1(),
            parentRef, actorSystemSendPort.sendPort, loggingProperties,
            data: {'feedbackPort': receivePort.sendPort});

        data = ActorCellTestData(actorCell, receivePort, streamQueue);
      });

      tearDown(() {
        parentReceivePort.close();

        receivePort.close();

        if (!actorCell.isDisposed) {
          actorCell.dispose();
        }
      });

      tearDownAll(() {
        actorSystemSendPort.close();
      });

      test('.initialize(). Initialize actor cell and check status.', () async {
        await PoolRouterActorCellTester().initializeTest(data);
      });

      test(
          '.start(). Start actor cell, receive message from cell and check status.',
          () async {
        await PoolRouterActorCellTester().startTest(data);
      });

      test(
          '.restart(). Restart actor cell, receive messages from cell and check status.',
          () async {
        await PoolRouterActorCellTester().restartTest(data);
      });

      test(
          '.pause(). Pause actor cell, receive messsages from cell and check status.',
          () async {
        await PoolRouterActorCellTester().pauseTest(data);
      });

      test(
          '.resume(). Resume actor cell, receive messages from cell and check status.',
          () async {
        await PoolRouterActorCellTester().resumeTest(data);
      });

      test('.kill(). Kill actor cell, receive messsage from cell.', () async {
        await PoolRouterActorCellTester().killTest(data);
      });

      test('equal operator. Compare cells.', () async {
        await PoolRouterActorCellTester().equalOperatorTest(data);
      });

      test('.dispose(). Dispose actor cell and check status.', () async {
        await PoolRouterActorCellTester().disposeTest(data);
      });
    });

    group('worker_actor_cell', () {
      var actorSystemSendPort = ReceivePort();

      var parentPath = ActorPath('test_system', 'test', 0);

      var path = parentPath.createChild('test_child');

      late ReceivePort parentReceivePort;

      late LocalActorRef parentRef;

      late ReceivePort receivePort;

      late StreamQueue streamQueue;

      late GroupRouterActorCell actorCell;

      late ActorCellTestData<GroupRouterActorCell> data;

      setUp(() {
        parentReceivePort = ReceivePort();

        parentRef = LocalActorRef(path, parentReceivePort.sendPort);

        receivePort = ReceivePort();

        streamQueue = StreamQueue(receivePort.asBroadcastStream());

        actorCell = GroupRouterActorCell(path, TestGroupRouterActor_1(),
            parentRef, actorSystemSendPort.sendPort, loggingProperties,
            data: {'feedbackPort': receivePort.sendPort});

        data = ActorCellTestData(actorCell, receivePort, streamQueue);
      });

      tearDown(() {
        parentReceivePort.close();

        receivePort.close();

        if (!actorCell.isDisposed) {
          actorCell.dispose();
        }
      });

      tearDownAll(() {
        actorSystemSendPort.close();
      });

      test('.initialize(). Initialize actor cell and check status.', () async {
        await GroupRouterActorCellTester().initializeTest(data);
      });

      test(
          '.start(). Start actor cell, receive message from cell and check status.',
          () async {
        await GroupRouterActorCellTester().startTest(data);
      });

      test(
          '.restart(). Restart actor cell, receive messages from cell and check status.',
          () async {
        await GroupRouterActorCellTester().restartTest(data);
      });

      test(
          '.pause(). Pause actor cell, receive messsages from cell and check status.',
          () async {
        await GroupRouterActorCellTester().pauseTest(data);
      });

      test(
          '.resume(). Resume actor cell, receive messages from cell and check status.',
          () async {
        await GroupRouterActorCellTester().resumeTest(data);
      });

      test('.kill(). Kill actor cell, receive messsage from cell.', () async {
        await GroupRouterActorCellTester().killTest(data);
      });

      test('equal operator. Compare cells.', () async {
        await GroupRouterActorCellTester().equalOperatorTest(data);
      });

      test('.dispose(). Dispose actor cell and check status.', () async {
        await GroupRouterActorCellTester().disposeTest(data);
      });
    });

    group('pool_router_actor_cell', () {
      var actorSystemSendPort = ReceivePort();

      var parentPath = ActorPath('test_system', 'test', 0);

      var path = parentPath.createChild('test_child');

      late ReceivePort parentReceivePort;

      late LocalActorRef parentRef;

      late ReceivePort receivePort;

      late StreamQueue streamQueue;

      late WorkerActorCell actorCell;

      late ActorCellTestData<WorkerActorCell> data;

      setUp(() {
        parentReceivePort = ReceivePort();

        parentRef = LocalActorRef(path, parentReceivePort.sendPort);

        receivePort = ReceivePort();

        streamQueue = StreamQueue(receivePort.asBroadcastStream());

        actorCell = WorkerActorCell(path, TestWorkerActor_2(), parentRef,
            actorSystemSendPort.sendPort, loggingProperties,
            data: {'feedbackPort': receivePort.sendPort});

        data = ActorCellTestData(actorCell, receivePort, streamQueue);
      });

      tearDown(() {
        parentReceivePort.close();

        receivePort.close();

        if (!actorCell.isDisposed) {
          actorCell.dispose();
        }
      });

      tearDownAll(() {
        actorSystemSendPort.close();
      });

      test('.initialize(). Initialize actor cell and check status.', () async {
        await WorkerActorCellTester().initializeTest(data);
      });

      test(
          '.start(). Start actor cell, receive message from cell and check status.',
          () async {
        await WorkerActorCellTester().startTest(data);
      });

      test(
          '.restart(). Restart actor cell, receive messages from cell and check status.',
          () async {
        await WorkerActorCellTester().restartTest(data);
      });

      test(
          '.pause(). Pause actor cell, receive messsages from cell and check status.',
          () async {
        await WorkerActorCellTester().pauseTest(data);
      });

      test(
          '.resume(). Resume actor cell, receive messages from cell and check status.',
          () async {
        await WorkerActorCellTester().resumeTest(data);
      });

      test('.kill(). Kill actor cell, receive messsage from cell.', () async {
        await WorkerActorCellTester().killTest(data);
      });

      test('equal operator. Compare cells.', () async {
        await WorkerActorCellTester().equalOperatorTest(data);
      });

      test('.dispose(). Dispose actor cell and check status.', () async {
        await WorkerActorCellTester().disposeTest(data);
      });
    });
  }, timeout: Timeout(Duration(seconds: 1)));
}
