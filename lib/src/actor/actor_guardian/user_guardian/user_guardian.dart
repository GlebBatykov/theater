part of theater.actor;

/// [UserGuardian] is a system top-level actor in actors tree. Is a supervisor for all user actors.
///
/// Created after [ActorSystem] initialized.
class UserGuardian extends UntypedActor {
  @override
  Future<void> onStart(context) async {}
}
