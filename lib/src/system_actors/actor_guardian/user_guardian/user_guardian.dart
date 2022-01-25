part of theater.system_actors;

/// [UserGuardian] is a system top-level actor in actors tree. Is a supervisor for all user actors.
///
/// Created after [ActorSystem] initialized.
class UserGuardian extends SystemActor {
  @override
  Future<void> handleSystemMessage(
      SystemActorContext context, SystemMessage message) async {
    var action = message.data;

    if (action is UserGuardianCreateTopLevelActor) {
      var ref = await context.actorOf(action.name, action.actor,
          data: action.data, onKill: action.onKill);

      message.sendResult(ref);
    } else if (action is UserGuardianDeleteTopLevelActor) {
    } else if (action is UserGuardianKillTopLevelActor) {
    } else if (action is UserGuardianPauseTopLevelActor) {
    } else if (action is UserGuardianResumeTopLevelActor) {
    } else if (action is UserGuardianStartTopLevelActor) {
    } else {
      message.successful();
    }
  }
}
