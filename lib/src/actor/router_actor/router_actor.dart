part of theater.actor;

/// This class is a base class for actor which the router.
///
/// Router is a special actor who routing messages between their children using routing strategy.
abstract class RouterActor extends NodeActor<RouterActorContext> {
  /// Creates instanse of [RouterDeployementStrategy] which the used for initialize router actor.
  RouterDeployementStrategy createDeployementStrategy();
}
