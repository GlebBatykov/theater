part of theater.actor;

/// Stores information about the actor that will be created in [GroupRouterActor].
class ActorInfo {
  /// Name of actor.
  final String name;

  /// Instanse of [NodeActor].
  final NodeActor actor;

  /// Some data that is transferred to the actor.
  final Map<String, dynamic>? data;

  ActorInfo({required this.name, required this.actor, this.data});
}
