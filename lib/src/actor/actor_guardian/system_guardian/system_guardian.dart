part of theater.actor;

/// [SystemGuardian] is a system top-level actor in actors tree. Is a supervisor for all system actors.
///
/// Created after [ActorSystem] initialized.
class SystemGuardian extends UntypedActor {
  @override
  Future<void> onStart(context) async {}
}
