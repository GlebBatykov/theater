part of theater.system_actors;

abstract class UserGuardianAction extends ActorAction {}

abstract class UserGuardianTopLevelActorAction extends UserGuardianAction {}

class UserGuardianCreateTopLevelActor extends UserGuardianTopLevelActorAction {
  final String name;

  final NodeActor actor;

  final Map<String, dynamic>? data;

  final void Function()? onKill;

  UserGuardianCreateTopLevelActor(
      this.name, this.actor, this.data, this.onKill);
}

class UserGuardianKillTopLevelActor extends UserGuardianTopLevelActorAction {
  final ActorPath path;

  UserGuardianKillTopLevelActor(this.path);
}

class UserGuardianPauseTopLevelActor extends UserGuardianTopLevelActorAction {
  final ActorPath path;

  UserGuardianPauseTopLevelActor(this.path);
}

class UserGuardianResumeTopLevelActor extends UserGuardianTopLevelActorAction {
  final ActorPath path;

  UserGuardianResumeTopLevelActor(this.path);
}

class UserGuardianStartTopLevelActor extends UserGuardianTopLevelActorAction {
  final ActorPath path;

  UserGuardianStartTopLevelActor(this.path);
}

class UserGuardianDeleteTopLevelActor extends UserGuardianTopLevelActorAction {
  final ActorPath path;

  UserGuardianDeleteTopLevelActor(this.path);
}
