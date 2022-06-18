part of theater.actor_system;

/// Is the base class for builder classes. The logic of creating an instance of the actor system is put into such classes.
abstract class ActorSystemBuilder {
  /// Build instance of [ActorSystem].
  ActorSystem build();
}
