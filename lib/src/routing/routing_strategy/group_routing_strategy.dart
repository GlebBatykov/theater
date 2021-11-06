part of theater.routing;

/// Used in [GroupRouterActor].
///
/// - roundRobin. Sends messages to actor group in round-robin order.
/// - broadcast. Sends any messages to all of actors in actor group.
/// - random. Sends message to random actor in actor group.
enum GroupRoutingStrategy { roundRobin, broadcast, random }
