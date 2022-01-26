part of theater.system_actors;

abstract class UserGuardianEvent {}

class UserGuardianCreateTopLevelActorSuccess extends UserGuardianEvent {
  final LocalActorRef ref;

  UserGuardianCreateTopLevelActorSuccess(this.ref);
}

class UserGuardianKillTopLevelActorSuccess extends UserGuardianEvent {}

class UserGuardianPauseTopLevelActorSuccess extends UserGuardianEvent {}

class UserGuardianResumeTopLevelActorSuccess extends UserGuardianEvent {}

class UserGuardianStartTopLevelActorSuccess extends UserGuardianEvent {}

class UserGuardianDeleteTopLevelActorSuccess extends UserGuardianEvent {}
