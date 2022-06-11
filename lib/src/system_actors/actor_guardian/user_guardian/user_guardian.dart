part of theater.system_actors;

/// [UserGuardian] is a system top-level actor in actors tree. Is a supervisor for all user actors.
///
/// Created after [ActorSystem] initialized.
class UserGuardian extends SystemActor {
  @override
  Future<void> handleSystemMessage(
      SystemActorContext context, SystemMessage message) async {
    var data = message.data;

    if (data is UserGuardianAction) {
      await _handleUserGuardianAction(context, message);
    }
  }

  Future<void> _handleUserGuardianAction(
      SystemActorContext context, SystemMessage message) async {
    var action = message.data;

    if (action is UserGuardianCreateTopLevelActor) {
      var ref = await context.actorOf(action.name, action.actor,
          data: action.data, onKill: action.onKill);

      message.sendResult(ref);
    } else if (action is UserGuardianDeleteTopLevelActor) {
      await context.deleteChild(action.path.toString());

      message.sendResult(UserGuardianDeleteTopLevelActorSuccess());
    } else if (action is UserGuardianKillTopLevelActor) {
      await context.killChild(action.path.toString());

      message.sendResult(UserGuardianKillTopLevelActorSuccess());
    } else if (action is UserGuardianPauseTopLevelActor) {
      await context.pauseChild(action.path.toString());

      message.sendResult(UserGuardianPauseTopLevelActorSuccess());
    } else if (action is UserGuardianResumeTopLevelActor) {
      await context.resumeChild(action.path.toString());

      message.sendResult(UserGuardianResumeTopLevelActorSuccess());
    } else if (action is UserGuardianStartTopLevelActor) {
      await context.startChild(action.path.toString());

      message.sendResult(UserGuardianStartTopLevelActorSuccess());
    } else {
      message.successful();
    }
  }
}
