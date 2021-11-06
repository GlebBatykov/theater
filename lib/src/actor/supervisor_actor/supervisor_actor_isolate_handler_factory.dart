part of theater.actor;

abstract class SupervisorActorIsolateHandlerFactory<
        H extends SupervisorActorIsolateHandler,
        A extends SupervisorActor,
        C extends SupervisorActorContext>
    extends ActorIsolateHandlerFactory<H, A, C> {}
