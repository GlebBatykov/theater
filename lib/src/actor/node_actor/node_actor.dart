part of theater.actor;

/// This class is a base class for actors is a node in actor tree.
///
/// Nodes in actor tree can create child actors. As a children, they may have sheet actor or other node actor.
abstract class NodeActor<T extends NodeActorContext>
    extends SupervisorActor<T> {
  NodeActorCellFactory _createActorCellFactory();
}
