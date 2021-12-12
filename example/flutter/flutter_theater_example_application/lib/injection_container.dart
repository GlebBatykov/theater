import 'package:flutter_theater_example_application/actor/test_actor.dart';
import 'package:get_it/get_it.dart';
import 'package:theater/theater.dart';

abstract class InjectionContainer {
  static Future<void> initialize() async {
    // Get [GetIt] instance
    var getIt = GetIt.instance;

    // Register dependency of [ActorSystem]
    getIt.registerLazySingletonAsync<ActorSystem>(() async {
      // Create actor system
      var system = ActorSystem('test_system');

      // Initialize actor system before work with it
      await system.initialize();

      return system;
    }, dispose: (system) async {
      // Dispose actor system
      await system.dispose();
    });

    // Register dependency of [LocalActorRef] with instance name 'test_actor_ref' to actor with name 'test_actor'
    getIt.registerLazySingletonAsync<LocalActorRef>(() async {
      // Get [ActorSystem] dependency for [GetIt]
      var system = await getIt.getAsync<ActorSystem>();

      // Create top-level actor in actor system with name 'test_actor'
      var ref = await system.actorOf('test_actor', TestActor());

      return ref;
    }, instanceName: 'test_actor_ref');
  }
}
