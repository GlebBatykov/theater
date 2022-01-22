part of theater.actor;

/// [SystemGuardian] is a system top-level actor in actors tree. Is a supervisor for all system actors.
///
/// Created after [ActorSystem] initialized.
class SystemGuardian extends SystemActor {
  final RemoteTransportConfiguration _remoteConfiguration;

  late LocalActorRef _actorSystemServerRef;

  SystemGuardian({required RemoteTransportConfiguration remoteConfiguration})
      : _remoteConfiguration = remoteConfiguration;

  @override
  Future<void> onStart(SystemActorContext context) async {
    if (_remoteConfiguration.isRemoteTransportEnabled) {
      _actorSystemServerRef = await context.actorOf(
          'actor_system_server', ActorSystemServerActor(_remoteConfiguration));
    }
  }
}
