part of theater.actor;

abstract class SupervisorActorCellFactory<A extends SupervisorActor,
        C extends SupervisorActorCell, P extends SupervisorActorCellProperties>
    extends ActorCellFactory<A, C, P> {}
