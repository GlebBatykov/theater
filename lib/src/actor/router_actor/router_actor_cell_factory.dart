part of theater.actor;

abstract class RouterActorCellFactory<
    A extends RouterActor,
    P extends RouterActorCell,
    C extends NodeActorCellProperties> extends NodeActorCellFactory<A, P, C> {}
