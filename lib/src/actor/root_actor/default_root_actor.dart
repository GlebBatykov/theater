part of theater.actor;

class DefaultRootActor extends RootActor {
  DefaultRootActor({required RemoteTransportConfiguration remoteConfiguration})
      : super(remoteConfiguration);

  @override
  Future<void> onStart(RootActorContext context) async {
    await context.actorOf(
        'system', SystemGuardian(remoteConfiguration: _remoteConfiguration));

    await context.actorOf('user', UserGuardian());
  }
}
