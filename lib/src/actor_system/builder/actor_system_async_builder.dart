part of theater.actor_system;

/// Is the base class for builder classes. The logic of asynchronous creating an instance of the actor system is put into such classes.
abstract class ActorSystemAsyncBuilder {
  /// Asynchronous build instance of [ActorSystem].
  Future<ActorSystem> build();
}
