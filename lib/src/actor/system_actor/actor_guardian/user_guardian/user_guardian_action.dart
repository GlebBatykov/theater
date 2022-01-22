part of theater.actor;

abstract class UserGuardianAction extends ActorAction {}

abstract class UserGuardianTopLevelActorAction extends UserGuardianAction {
  final String name;

  UserGuardianTopLevelActorAction(this.name);
}

class UserGuardianCreateTopLevelActor extends UserGuardianTopLevelActorAction {
  final NodeActor actor;

  final Map<String, dynamic>? data;

  final void Function()? onKill;

  UserGuardianCreateTopLevelActor(
      String name, this.actor, this.data, this.onKill)
      : super(name);
}

class UserGuardianKillTopLevelActor extends UserGuardianTopLevelActorAction {
  UserGuardianKillTopLevelActor(String name) : super(name);
}

class UserGuardianPauseTopLevelActor extends UserGuardianTopLevelActorAction {
  UserGuardianPauseTopLevelActor(String name) : super(name);
}

class UserGuardianResumeTopLevelActor extends UserGuardianTopLevelActorAction {
  UserGuardianResumeTopLevelActor(String name) : super(name);
}

class UserGuardianStartTopLevelActor extends UserGuardianTopLevelActorAction {
  UserGuardianStartTopLevelActor(String name) : super(name);
}

class UserGuardianDeleteTopLevelActor extends UserGuardianTopLevelActorAction {
  UserGuardianDeleteTopLevelActor(String name) : super(name);
}
