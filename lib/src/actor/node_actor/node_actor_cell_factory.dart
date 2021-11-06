part of theater.actor;

abstract class NodeActorCellFactory<A extends NodeActor,
        C extends NodeActorCell, P extends NodeActorCellProperties>
    extends SupervisorActorCellFactory<A, C, P> {}
