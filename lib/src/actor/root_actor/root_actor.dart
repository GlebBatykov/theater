part of theater.actor;

abstract class RootActor extends SupervisorActor<RootActorContext> {
  @override
  Future<void> onStart(RootActorContext context) async {}

  @override
  Future<void> onKill(RootActorContext context) async {}

  @override
  Future<void> onPause(RootActorContext context) async {}

  @override
  Future<void> onResume(RootActorContext context) async {}
}
