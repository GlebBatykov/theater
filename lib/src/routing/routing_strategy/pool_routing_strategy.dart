part of theater.routing;

/// Used in [PoolRouterActor].
///
/// - roundRobin. Sends messages to worker pool in round-robin order.
/// - broadcast. Sends any messages to all of workers in worker group.
/// - random. Sends message to random worker in workers group.
/// - balancing. Sends message to worker which processes the least number of messages at the moment.
enum PoolRoutingStrategy { roundRobin, broadcast, random, balancing }
