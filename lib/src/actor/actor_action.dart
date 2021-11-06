part of theater.actor;

abstract class ActorAction {}

class ActorStart extends ActorAction {}

class ActorKill extends ActorAction {}

class ActorPause extends ActorAction {}

class ActorResume extends ActorAction {}

class ActorCreateChild extends ActorAction {
  final String name;

  final NodeActor actor;

  final Map<String, dynamic>? data;

  final void Function()? onKill;

  ActorCreateChild(this.name, this.actor, this.data, this.onKill);
}
