part of theater.actor;

abstract class UserGuardianAction extends ActorAction {}

class UserGuardianCreateTopLevelActor extends UserGuardianAction {
  final String name;

  final NodeActor actor;

  final Map<String, dynamic>? data;

  final void Function()? onKill;

  UserGuardianCreateTopLevelActor(
      this.name, this.actor, this.data, this.onKill);
}
