part of theater.system_actors;

class DefaultRootActor extends RootActor {
  DefaultRootActor({required RemoteTransportConfiguration remoteConfiguration})
      : super(remoteConfiguration);

  @override
  Future<void> onStart(RootActorContext context) async {
    await context.actorOf(
        'system', SystemGuardian(remoteConfiguration: remoteConfiguration));

    await context.actorOf('user', UserGuardian());
  }
}
