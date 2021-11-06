part of theater.actor;

abstract class NodeActorIsolateHandlerFactory<
    H extends NodeActorIsolateHandler,
    A extends NodeActor,
    C extends NodeActorContext> extends ActorIsolateHandlerFactory<H, A, C> {}
