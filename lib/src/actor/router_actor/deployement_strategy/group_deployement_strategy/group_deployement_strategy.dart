part of theater.actor;

/// Class is used by initialization in [GroupRouterActor].
/// It contains information about the actors that must be created in the group of actors, and also about the algorithms for implementing the routing system.
class GroupDeployementStrategy extends RouterDeployementStrategy {
  /// Routing strategy is used by message routing in [GroupRouterActor].
  final GroupRoutingStrategy routingStrategy;

  /// Actor group info is used by creating actor group in [GroupRouterActor].
  final List<ActorInfo> group;

  GroupDeployementStrategy(
      {required this.routingStrategy, required this.group});
}
