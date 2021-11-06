part of theater.actor;

abstract class SheetActorIsolateHandlerFactory<
    H extends SheetActorIsolateHandler,
    A extends SheetActor,
    C extends SheetActorContext> extends ActorIsolateHandlerFactory<H, A, C> {}
