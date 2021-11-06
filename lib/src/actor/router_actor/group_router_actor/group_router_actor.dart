part of theater.actor;

/// This class is a base class for actors routers who create group of actorsduring initialization.
///
/// Group of actors may consists of the various type of [NodeActor].
abstract class GroupRouterActor extends RouterActor {
  /// Creates instanse of [GroupDeployementStrategy] which the used for initialize [GroupRouterActor].
  @override
  GroupDeployementStrategy createDeployementStrategy();

  @override
  GroupRouterActorCellFactory _createActorCellFactory() =>
      GroupRouterActorCellFactory();
}
