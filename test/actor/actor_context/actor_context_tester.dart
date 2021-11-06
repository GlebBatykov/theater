import 'package:test/test.dart';
import 'package:theater/src/actor.dart';

import 'actor_context_test_data.dart';

abstract class ActorContextTester<T extends ActorContext> {
  Future<void> killTest(ActorContextTestData<T> data) async {
    data.actorContext.kill();

    expect(await data.supervisorMessagePort.first, isA<ActorWantsToDie>());
  }

  Future<void> sendWithAbsolutePath(ActorContextTestData<T> data);

  Future<void> sendWithRelativePath(ActorContextTestData<T> data);

  Future<void> sendToHimself(ActorContextTestData<T> data);
}
