part of theater.actor;

class DefaultRootActor extends RootActor {
  @override
  Future<void> onStart(context) async {
    await context.actorOf('system', SystemGuardian());

    await context.actorOf('user', UserGuardian());
  }
}
