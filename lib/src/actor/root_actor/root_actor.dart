part of theater.actor;

abstract class RootActor extends SupervisorActor<RootActorContext> {
  final RemoteTransportConfiguration remoteConfiguration;

  RootActor(this.remoteConfiguration);
}
