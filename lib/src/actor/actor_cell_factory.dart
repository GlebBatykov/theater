part of theater.actor;

abstract class ActorCellFactory<A extends Actor, C extends ActorCell,
    P extends ActorCellProperties> {
  C create(ActorPath path, A actor, P properties);
}
