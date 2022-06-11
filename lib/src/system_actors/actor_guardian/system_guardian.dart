part of theater.system_actors;

/// [SystemGuardian] is a system top-level actor in actors tree. Is a supervisor for all system actors.
///
/// Created after [ActorSystem] initialized.
class SystemGuardian extends SystemActor {
  final RemoteTransportConfiguration _remoteConfiguration;

  // ignore: unused_field
  late LocalActorRef _actorSystemServerRef;

  SystemGuardian({required RemoteTransportConfiguration remoteConfiguration})
      : _remoteConfiguration = remoteConfiguration;

  @override
  Future<void> onStart(SystemActorContext context) async {
    if (_remoteConfiguration.isRemoteTransportEnabled) {
      _actorSystemServerRef = await context.actorOf(
          SystemActorNames.actorSystemServer,
          ActorSystemServerActor(_remoteConfiguration));
    }
  }
}
