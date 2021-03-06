import 'dart:isolate';

import 'package:test/scaffolding.dart';
import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';
import 'package:theater/src/isolate.dart';
import 'package:theater/src/routing.dart';
import 'package:theater/src/supervising.dart';

import 'actor_context/actor_context_test_data.dart';
import 'actor_context/group_router_actor/group_router_actor_context_tester.dart';
import 'actor_context/pool_router_actor/test_worker_actor_factory_1.dart';
import 'actor_context/pool_router_actor/pool_router_actor_context_tester.dart';
import 'actor_context/root_actor_context_tester.dart';
import 'actor_context/test_actor/test_untyped_actor_2.dart';
import 'actor_context/test_actor/test_untyped_actor_3.dart';
import 'actor_context/untyped_actor_context_tester.dart';
import 'actor_context/worker_actor_context_tester.dart';

void main() {
  group('actor_context', () {
    group('root_actor_context', () {
      var actorSystemMessagePort = ReceivePort();

      var path = ActorPath(Address('test_system'), 'test', 0);

      late UnreliableMailbox mailbox;

      late LocalActorRef actorRef;

      late ReceivePort isolateReceivePort;

      late ReceivePort supervisorMessagePort;

      late ReceivePort supervisorErrorPort;

      late IsolateContext isolateContext;

      late RootActorContext context;

      late ActorContextTestData<RootActorContext> data;

      late ReceivePort feedbackPort;

      setUp(() {
        mailbox = UnreliableMailbox(path);

        actorRef = LocalActorRef(path, mailbox.sendPort);

        isolateReceivePort = ReceivePort();

        supervisorMessagePort = ReceivePort();

        supervisorErrorPort = ReceivePort();

        isolateContext = IsolateContext(isolateReceivePort,
            supervisorMessagePort.sendPort, supervisorErrorPort.sendPort);

        context = RootActorContext(
            isolateContext,
            RootActorProperties(
                actorRef: actorRef,
                supervisorStrategy:
                    OneForOneStrategy(decider: DefaultDecider()),
                mailboxType: MailboxType.unreliable,
                actorSystemMessagePort: actorSystemMessagePort.sendPort));

        feedbackPort = ReceivePort();

        data = ActorContextTestData(context, mailbox, isolateContext,
            supervisorMessagePort, supervisorErrorPort, actorSystemMessagePort,
            feedbackPort: feedbackPort);
      });

      tearDown(() async {
        await mailbox.dispose();

        isolateReceivePort.close();

        supervisorMessagePort.close();

        supervisorErrorPort.close();

        feedbackPort.close();

        await context.killChildren();
      });

      tearDownAll(() {
        actorSystemMessagePort.close();
      });

      test(
          '.kill(). Calls .kill() method and receives [ActorWantsToDie] event in him supervisor port.',
          () async {
        await RootActorContextTester().killTest(data);
      });

      group('.sendAndSubscribe().', () {
        test(
            'With absolute path. Creates child actor with name \'test_child\', sends message to him using absolute path to him, receives response.',
            () async {
          await RootActorContextTester().sendAndSubscribeWithAbsolutePath(data);
        });

        test(
            'With relative path. Creates child actor with name \'test_child\', sends message to him using relative path to him, receives response.',
            () async {
          await RootActorContextTester().sendAndSubscribeWithRelativePath(data);
        });

        test('Send to himself. Sends message to himself using absolute path.',
            () async {
          await RootActorContextTester().sendAndSubscribeToHimself(data);
        });
      });

      test('.sendToTopic(). Sends message to actor system topic.', () async {
        await RootActorContextTester().sendToTopicTest(data);
      });

      test('.actorOf(). Creates child actor and receives 5 message from him.',
          () async {
        await RootActorContextTester().actorOfTest(data);
      });

      test(
          '.killChildren(). Kills all child actor and receives messages from their.',
          () async {
        await RootActorContextTester().killChildrenTest(data);
      });

      test(
          '.pauseChildren(). Pauses all child actor and receives messages from their.',
          () async {
        await RootActorContextTester().pauseChildrenTest(data);
      });

      test(
          '.resumeChildren(). Resumes all child actor and receives messages from their.',
          () async {
        await RootActorContextTester().resumeChildrenTest(data);
      });

      test(
          '.restartChildren(). Restarts all child actor and receievs messages from their.',
          () async {
        await RootActorContextTester().restartChildrenTest(data);
      }, timeout: Timeout(Duration(milliseconds: 1500)));
    });

    group('untyped_actor_context', () {
      var actorSystemMessagePort = ReceivePort();

      var parentPath = ActorPath(Address('test_system'), 'test_root', 0);

      var path = parentPath.createChild('test');

      late UnreliableMailbox parentMailbox;

      late LocalActorRef parentRef;

      late UnreliableMailbox mailbox;

      late LocalActorRef actorRef;

      late ReceivePort isolateReceivePort;

      late ReceivePort supervisorMessagePort;

      late ReceivePort supervisorErrorPort;

      late IsolateContext isolateContext;

      late UntypedActorContext context;

      late ActorContextTestData<UntypedActorContext> data;

      late ReceivePort feedbackPort;

      setUp(() {
        parentMailbox = UnreliableMailbox(parentPath);

        parentRef = LocalActorRef(parentPath, parentMailbox.sendPort);

        mailbox = UnreliableMailbox(path);

        actorRef = LocalActorRef(path, mailbox.sendPort);

        isolateReceivePort = ReceivePort();

        supervisorMessagePort = ReceivePort();

        supervisorErrorPort = ReceivePort();

        isolateContext = IsolateContext(isolateReceivePort,
            supervisorMessagePort.sendPort, supervisorErrorPort.sendPort);

        feedbackPort = ReceivePort();

        context = UntypedActorContext(
            isolateContext,
            UntypedActorProperties(
                parentRef: parentRef,
                actorRef: actorRef,
                supervisorStrategy:
                    OneForOneStrategy(decider: DefaultDecider()),
                mailboxType: MailboxType.unreliable,
                actorSystemMessagePort: actorSystemMessagePort.sendPort));

        data = ActorContextTestData(context, mailbox, isolateContext,
            supervisorMessagePort, supervisorErrorPort, actorSystemMessagePort,
            parentMailbox: parentMailbox, feedbackPort: feedbackPort);
      });

      tearDown(() async {
        await parentMailbox.dispose();

        await mailbox.dispose();

        isolateReceivePort.close();

        supervisorMessagePort.close();

        supervisorErrorPort.close();

        await context.killChildren();
      });

      tearDownAll(() {
        actorSystemMessagePort.close();
      });

      test(
          '.kill(). Calls .kill() method and receives [ActorWantsToDie] event in him supervisor port.',
          () async {
        await UntypedActorContextTester().killTest(data);
      });

      group('.send(). ', () {
        test(
            'With absolute path. Sends message to parent actor using absolute path to him.',
            () async {
          await UntypedActorContextTester()
              .sendAndSubscribeWithAbsolutePath(data);
        });

        test(
            'With relative path. Creates child actor with name \'test_child\' and sends messege to him using relative path.',
            () async {
          await UntypedActorContextTester()
              .sendAndSubscribeWithRelativePath(data);
        });

        test('Send to himself. Sends message to himself using absolute path.',
            () async {
          await UntypedActorContextTester().sendAndSubscribeToHimself(data);
        });
      });

      test('.sendToTopic(). Sends message to actor system topic.', () async {
        await UntypedActorContextTester().sendToTopicTest(data);
      });

      test('.actorOf(). Creates child actor and receives 5 message from him.',
          () async {
        await UntypedActorContextTester().actorOfTest(data);
      });

      test(
          '.killChildren(). Creates 5 child actors, kills all child actor and receives messages from their.',
          () async {
        await UntypedActorContextTester().killChildrenTest(data);
      });

      test(
          '.pauseChildren(). Creates 5 child actors, pauses all child actor and receives messages from their.',
          () async {
        await UntypedActorContextTester().pauseChildrenTest(data);
      });

      test(
          '.resumeChildren(). Creates 5 child actors, resumes all child actor and receives messages from their.',
          () async {
        await UntypedActorContextTester().resumeChildrenTest(data);
      });

      test(
          '.restartChildren(). Creates 5 child actors, restarts all child actor and receievs messages from their.',
          () async {
        await UntypedActorContextTester().restartChildrenTest(data);
      }, timeout: Timeout(Duration(milliseconds: 1500)));
    });

    group('group_router_actor_context', () {
      var actorSystemMessagePort = ReceivePort();

      var parentPath = ActorPath(Address('test_system'), 'test_root', 0);

      var path = parentPath.createChild('test');

      late UnreliableMailbox parentMailbox;

      late LocalActorRef parentRef;

      late UnreliableMailbox mailbox;

      late LocalActorRef actorRef;

      late ReceivePort isolateReceivePort;

      late ReceivePort supervisorMessagePort;

      late ReceivePort supervisorErrorPort;

      late IsolateContext isolateContext;

      late GroupRouterActorContext context;

      late ActorContextTestData<GroupRouterActorContext> data;

      late ReceivePort feedbackPort;

      Future<GroupRouterActorContext> createContext(List<ActorInfo> group,
          [GroupRoutingStrategy strategy =
              GroupRoutingStrategy.broadcast]) async {
        var properties = GroupRouterActorProperties(
            parentRef: parentRef,
            actorRef: actorRef,
            deployementStrategy: GroupDeployementStrategy(
                routingStrategy: strategy, group: group),
            supervisorStrategy: OneForOneStrategy(decider: DefaultDecider()),
            mailboxType: MailboxType.unreliable,
            actorSystemMessagePort: actorSystemMessagePort.sendPort);

        return await GroupRouterActorContextBuilder()
            .build(isolateContext, properties);
      }

      ActorContextTestData<GroupRouterActorContext> createTestData() =>
          ActorContextTestData(
              context,
              mailbox,
              isolateContext,
              supervisorMessagePort,
              supervisorErrorPort,
              actorSystemMessagePort,
              parentMailbox: parentMailbox,
              feedbackPort: feedbackPort,
              isolateReceivePort: isolateReceivePort);

      setUp(() {
        parentMailbox = UnreliableMailbox(parentPath);

        parentRef = LocalActorRef(parentPath, parentMailbox.sendPort);

        mailbox = UnreliableMailbox(path);

        actorRef = LocalActorRef(path, mailbox.sendPort);

        isolateReceivePort = ReceivePort();

        supervisorMessagePort = ReceivePort();

        supervisorErrorPort = ReceivePort();

        isolateContext = IsolateContext(isolateReceivePort,
            supervisorMessagePort.sendPort, supervisorErrorPort.sendPort);

        feedbackPort = ReceivePort();
      });

      tearDown(() async {
        await parentMailbox.dispose();

        await mailbox.dispose();

        isolateReceivePort.close();

        supervisorMessagePort.close();

        supervisorErrorPort.close();

        feedbackPort.close();

        await context.killChildren();
      });

      tearDownAll(() {
        actorSystemMessagePort.close();
      });

      test(
          '.kill(). Calls .kill() method and receives [ActorWantsToDie] event in him supervisor port.',
          () async {
        context = await createContext(List.generate(
            5,
            (index) => ActorInfo(
                name: 'test_' + index.toString(),
                actor: TestUntypedActor_2(),
                data: {'feedbackPort': feedbackPort.sendPort})));

        data = createTestData();

        await GroupRounterActorContextTester().killTest(data);
      });

      group('.sendAndSubscribe().', () {
        test(
            'With absolute path. Sends message to parent actor using absolute path to him.',
            () async {
          context = await createContext(List.generate(
              5,
              (index) => ActorInfo(
                  name: 'test_' + index.toString(),
                  actor: TestUntypedActor_2(),
                  data: {'feedbackPort': feedbackPort.sendPort})));

          data = createTestData();

          await GroupRounterActorContextTester()
              .sendAndSubscribeWithAbsolutePath(data);
        });

        test(
            'With relative path. Sends message to child actor in actor group with relative path to him.',
            () async {
          context = await createContext(List.generate(
              5,
              (index) => ActorInfo(
                  name: 'test_' + index.toString(),
                  actor: TestUntypedActor_2(),
                  data: {'feedbackPort': feedbackPort.sendPort})));

          data = createTestData();

          await GroupRounterActorContextTester()
              .sendAndSubscribeWithRelativePath(data);
        });

        test('Send to himself. Sends message to himself using absolute path.',
            () async {
          context = await createContext(List.generate(
              5,
              (index) => ActorInfo(
                  name: 'test_' + index.toString(),
                  actor: TestUntypedActor_2(),
                  data: {'feedbackPort': feedbackPort.sendPort})));

          data = createTestData();

          await GroupRounterActorContextTester()
              .sendAndSubscribeToHimself(data);
        });
      });

      test('.sendToTopic(). Sends message to actor system topic.', () async {
        context = await createContext(List.generate(
            5,
            (index) => ActorInfo(
                name: 'test_' + index.toString(),
                actor: TestUntypedActor_2(),
                data: {'feedbackPort': feedbackPort.sendPort})));

        data = createTestData();

        await GroupRounterActorContextTester().sendToTopicTest(data);
      });

      group('routing.', () {
        test(
            'With broadcast routing strategy. Creates actor group with 5 child actors, set .broadcast routing strategy and send message to himselft. Receives 5 response from actors in actor group.',
            () async {
          context = await createContext(
              List.generate(
                  5,
                  (index) => ActorInfo(
                      name: 'test_' + index.toString(),
                      actor: TestUntypedActor_2(),
                      data: {'feedbackPort': feedbackPort.sendPort})),
              GroupRoutingStrategy.broadcast);

          data = createTestData();

          await GroupRounterActorContextTester().routingBroadcastTest(data);
        });

        test(
            'With random routing strategy. Creates actor group with 5 child actors, set .random routing strategy and send 5 messages to himself. Receives 5 response from actors in actor group and checks time spent processing messages.',
            () async {
          context = await createContext(
              List.generate(
                  5,
                  (index) => ActorInfo(
                      name: 'test_' + index.toString(),
                      actor: TestUntypedActor_3(),
                      data: {'feedbackPort': feedbackPort.sendPort})),
              GroupRoutingStrategy.random);

          data = createTestData();

          await GroupRounterActorContextTester().routingRandomTest(data);
        });

        test(
            'With round robin routing strategy. Creates actor group with 5 child actors, set .roundRobin routing strategy and send 5 messages to himself. Receives 5 response from actors in actor group and checks time spent processsing messages.',
            () async {
          context = await createContext(
              List.generate(
                  5,
                  (index) => ActorInfo(
                      name: 'test_' + index.toString(),
                      actor: TestUntypedActor_3(),
                      data: {'feedbackPort': feedbackPort.sendPort})),
              GroupRoutingStrategy.roundRobin);

          data = createTestData();

          await GroupRounterActorContextTester().routingRoundRobinTest(data);
        });
      });

      test(
          '.killChildren(). Creates 5 child actors in actor group, kills all child actor and receives messages from their.',
          () async {
        context = await createContext(List.generate(
            5,
            (index) => ActorInfo(
                name: 'test_' + index.toString(),
                actor: TestUntypedActor_2(),
                data: {'feedbackPort': feedbackPort.sendPort})));

        data = createTestData();

        await GroupRounterActorContextTester().killChildrenTest(data);
      });

      test(
          '.pauseChildren(). Creates 5 child actors in actor group, pauses all child actor and receives messages from their.',
          () async {
        context = await createContext(List.generate(
            5,
            (index) => ActorInfo(
                name: 'test_' + index.toString(),
                actor: TestUntypedActor_2(),
                data: {'feedbackPort': feedbackPort.sendPort})));

        data = createTestData();

        await GroupRounterActorContextTester().pauseChildrenTest(data);
      });

      test(
          '.resumeChildren(). Creates 5 child actors in actor group, resumes all child actor and receives messages from their.',
          () async {
        context = await createContext(List.generate(
            5,
            (index) => ActorInfo(
                name: 'test_' + index.toString(),
                actor: TestUntypedActor_2(),
                data: {'feedbackPort': feedbackPort.sendPort})));

        data = createTestData();

        await GroupRounterActorContextTester().resumeChildrenTest(data);
      });

      test(
          '.restartChildren(). Creates 5 child actors in actor group, restarts all child actor and receievs messages from their.',
          () async {
        context = await createContext(List.generate(
            5,
            (index) => ActorInfo(
                name: 'test_' + index.toString(),
                actor: TestUntypedActor_2(),
                data: {'feedbackPort': feedbackPort.sendPort})));

        data = createTestData();

        await GroupRounterActorContextTester().restartChildrenTest(data);
      });
    });

    group('pool_router_actor_context', () {
      var actorSystemMessagePort = ReceivePort();

      var parentPath = ActorPath(Address('test_system'), 'test_root', 0);

      var path = parentPath.createChild('test');

      late UnreliableMailbox parentMailbox;

      late LocalActorRef parentRef;

      late UnreliableMailbox mailbox;

      late LocalActorRef actorRef;

      late ReceivePort isolateReceivePort;

      late ReceivePort supervisorMessagePort;

      late ReceivePort supervisorErrorPort;

      late IsolateContext isolateContext;

      late PoolRouterActorContext context;

      late ActorContextTestData<PoolRouterActorContext> data;

      late ReceivePort feedbackPort;

      Future<PoolRouterActorContext> createContext(
          [PoolRoutingStrategy strategy =
              PoolRoutingStrategy.broadcast]) async {
        var properties = PoolRouterActorProperties(
            parentRef: parentRef,
            actorRef: actorRef,
            deployementStrategy: PoolDeployementStrategy(
                workerFactory: TestWorkerActorFactory_1(),
                poolSize: 5,
                routingStrategy: strategy,
                data: {'feedbackPort': feedbackPort.sendPort}),
            supervisorStrategy: OneForOneStrategy(decider: DefaultDecider()),
            mailboxType: MailboxType.unreliable,
            actorSystemMessagePort: actorSystemMessagePort.sendPort);

        return await PoolRouterActorContextBuilder()
            .build(isolateContext, properties);
      }

      ActorContextTestData<PoolRouterActorContext> createTestData() =>
          ActorContextTestData(
              context,
              mailbox,
              isolateContext,
              supervisorMessagePort,
              supervisorErrorPort,
              actorSystemMessagePort,
              parentMailbox: parentMailbox,
              feedbackPort: feedbackPort,
              isolateReceivePort: isolateReceivePort);

      setUp(() {
        parentMailbox = UnreliableMailbox(parentPath);

        parentRef = LocalActorRef(parentPath, parentMailbox.sendPort);

        mailbox = UnreliableMailbox(path);

        actorRef = LocalActorRef(path, mailbox.sendPort);

        isolateReceivePort = ReceivePort();

        supervisorMessagePort = ReceivePort();

        supervisorErrorPort = ReceivePort();

        isolateContext = IsolateContext(isolateReceivePort,
            supervisorMessagePort.sendPort, supervisorErrorPort.sendPort);

        feedbackPort = ReceivePort();
      });

      tearDown(() async {
        await parentMailbox.dispose();

        await mailbox.dispose();

        isolateReceivePort.close();

        supervisorMessagePort.close();

        supervisorErrorPort.close();

        feedbackPort.close();

        await context.killChildren();
      });

      tearDownAll(() {
        actorSystemMessagePort.close();
      });

      test(
          '.kill(). Calls .kill() method and receives [ActorWantsToDie] event in him supervisor port.',
          () async {
        context = await createContext();

        data = createTestData();

        await PoolRouterActorContextTester().killTest(data);
      });

      group('.sendAndSubscribe().', () {
        test(
            'With absolute path. Sends message to parent actor using absolute path to him.',
            () async {
          context = await createContext();

          data = createTestData();

          await PoolRouterActorContextTester()
              .sendAndSubscribeWithAbsolutePath(data);
        });

        test(
            'With relative path. Sends message to child actor with relative path, receive response - instanse of RecipientNotFoundResult.',
            () async {
          context = await createContext();

          data = createTestData();

          await PoolRouterActorContextTester()
              .sendAndSubscribeWithRelativePath(data);
        });

        test('Send to himself. Sends message to himself using absolute path.',
            () async {
          context = await createContext();

          data = createTestData();

          await PoolRouterActorContextTester().sendAndSubscribeToHimself(data);
        });
      });

      test('.sendToTopic(). Sends message to actor system topic.', () async {
        context = await createContext();

        data = createTestData();

        await PoolRouterActorContextTester().sendToTopicTest(data);
      });

      group('routing.', () {
        test(
            'With broadcast routing strategy. Creates worker pool with 5 workers, set .broadcast routing strategy and send message to himselft. Receives 5 response from workers in worker pool.',
            () async {
          context = await createContext();

          data = createTestData();

          await PoolRouterActorContextTester().routingBroadcastTest(data);
        });

        test(
            'With random routing strategy. Creates worker pool with 5 workers, set .random routing strategy and send 5 messages to himself. Receives 5 response from workers in worker pool and checks time spent processing messages.',
            () async {
          context = await createContext(PoolRoutingStrategy.random);

          data = createTestData();

          await PoolRouterActorContextTester().routingRandomTest(data);
        });

        test(
            'With round robing routing strategy. Creates worker pool with 5 child workers, set .roundRobin routing strategy and send 5 messages to himself. Receives 5 response from workers in worker pool and checks time spent processsing messages.',
            () async {
          context = await createContext(PoolRoutingStrategy.roundRobin);

          data = createTestData();

          await PoolRouterActorContextTester().routingRoundRobinTest(data);
        });

        test(
            'With balancing routing strategy. Creates worker pool with 5 child workers, set .balancing routing strategy and send 5 messages to himself. Receives 5 response from workers in worker pool and checks time spent processsing messages.',
            () async {
          context = await createContext(PoolRoutingStrategy.roundRobin);

          data = createTestData();

          await PoolRouterActorContextTester().routingBalancingTest(data);
        });
      });

      test(
          '.killChildren(). Creates 5 workers in worker pool, kills all child actor (workers) and receives messages from their.',
          () async {
        context = await createContext();

        data = createTestData();

        await PoolRouterActorContextTester().killChildrenTest(data);
      });

      test(
          '.pauseChildren(). Creates 5 workers in worker pool, pauses all child actor (workers) and receives messages from their.',
          () async {
        context = await createContext();

        data = createTestData();

        await PoolRouterActorContextTester().pauseChildrenTest(data);
      });

      test(
          '.resumeChildren(). Creates 5 workers in worker pool, resumes all child actor (workers) and receives messages from their.',
          () async {
        context = await createContext();

        data = createTestData();

        await PoolRouterActorContextTester().resumeChildrenTest(data);
      });

      test(
          '.restartChildren(). Creates 5 workers in worker pool, restarts all child actor (workers) and receievs messages from their.',
          () async {
        context = await createContext();

        data = createTestData();

        await PoolRouterActorContextTester().restartChildrenTest(data);
      });
    });

    group('system_actor_context', () {
      test('.kill(). ', () async {});

      group('.sendAndSubscribe().', () {
        test('With absolute path. ', () async {});

        test('With relative path. ', () async {});

        test('Send to himself. ', () async {});
      });

      test('.sendToTopic(). ', () async {});

      test('.actorOf(). ', () async {});

      test('.killChildrens(). ', () async {});

      test('.pauseChildrens(). ', () async {});

      test('.resumeChildrens(). ', () async {});

      test('.restartChildrens(). ', () async {});
    });

    group('worker_actor_context', () {
      var actorSystemMessagePort = ReceivePort();

      var parentPath = ActorPath(Address('test_system'), 'test_root', 0);

      var path = parentPath.createChild('worker');

      late UnreliableMailbox parentMailbox;

      late LocalActorRef parentRef;

      late UnreliableMailbox mailbox;

      late LocalActorRef actorRef;

      late ReceivePort isolateReceivePort;

      late ReceivePort supervisorMessagePort;

      late ReceivePort supervisorErrorPort;

      late IsolateContext isolateContext;

      late WorkerActorContext context;

      late ActorContextTestData<WorkerActorContext> data;

      setUp(() {
        parentMailbox = UnreliableMailbox(parentPath);

        parentRef = LocalActorRef(parentPath, parentMailbox.sendPort);

        mailbox = UnreliableMailbox(path);

        actorRef = LocalActorRef(path, mailbox.sendPort);

        isolateReceivePort = ReceivePort();

        supervisorMessagePort = ReceivePort();

        supervisorErrorPort = ReceivePort();

        isolateContext = IsolateContext(isolateReceivePort,
            supervisorMessagePort.sendPort, supervisorErrorPort.sendPort);

        context = WorkerActorContext(
            isolateContext,
            WorkerActorProperties(
                parentRef: parentRef,
                actorRef: actorRef,
                mailboxType: MailboxType.unreliable,
                actorSystemMessagePort: actorSystemMessagePort.sendPort));

        data = ActorContextTestData(context, mailbox, isolateContext,
            supervisorMessagePort, supervisorErrorPort, actorSystemMessagePort,
            parentMailbox: parentMailbox);
      });

      tearDown(() async {
        await parentMailbox.dispose();

        await mailbox.dispose();

        isolateReceivePort.close();

        supervisorMessagePort.close();

        supervisorErrorPort.close();
      });

      tearDownAll(() {
        actorSystemMessagePort.close();
      });

      test(
          '.kill(). Calls .kill() method and receives [ActorWantsToDie] event in him supervisor port.',
          () async {
        await WorkerActorContextTester().killTest(data);
      });

      group('.sendAndSubscribe(). ', () {
        test(
            'With absolute path. Sends message to parent actor using absolute path to him.',
            () async {
          await WorkerActorContextTester()
              .sendAndSubscribeWithAbsolutePath(data);
        });

        test(
            'With relative path. Sends message to child actor (worker don\'t have child actors) with relative path, receive response - instanse of RecipientNotFoundResult.',
            () async {
          await WorkerActorContextTester()
              .sendAndSubscribeWithRelativePath(data);
        });

        test('Send to himself. Sends message to himself using absolute path.',
            () async {
          await WorkerActorContextTester().sendAndSubscribeToHimself(data);
        });
      });

      test('.sendToTopic(). Sends message to actor system topic.', () async {
        await WorkerActorContextTester().sendToTopicTest(data);
      });
    });
  }, timeout: Timeout(Duration(seconds: 1)));
}
