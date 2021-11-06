part of theater.actor;

/// This class is a base class for actors who is a sheet in actor tree.
///
/// Sheets in actor tree can't creates children.
abstract class SheetActor<T extends SheetActorContext>
    extends ObservableActor<T> {
  SheetActorCellFactory _createActorCellFactory();
}
