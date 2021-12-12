part of theater.actor;

/// [UserGuardian] is a system top-level actor in actors tree. Is a supervisor for all user actors.
///
/// Created after [ActorSystem] initialized.
class UserGuardian extends SystemActor {
  @override
  Future<void> handleRoutingSystemMessage(
      SystemActorContext context, SystemRoutingMessage message) async {
    var action = message.data;

    if (action is UserGuardianCreateTopLevelActor) {
      var ref = await context.actorOf(action.name, action.actor,
          data: action.data, onKill: action.onKill);

      message.sendResult(ref);
    } else {
      message.successful();
    }
  }
}
