part of theater.actor;

abstract class SheetActorCellFactory<
    A extends SheetActor,
    C extends SheetActorCell,
    P extends SheetActorCellProperties> extends ActorCellFactory<A, C, P> {}
