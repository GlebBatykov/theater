part of theater.actor;

abstract class ActorRefFactory<A extends Actor> {
  Future<LocalActorRef> actorOf<T extends A>(String name, T handler,
      {Map<String, dynamic> data, void Function()? onKill});
}
