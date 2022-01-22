part of theater.actor;

abstract class RootActor extends SupervisorActor<RootActorContext> {
  final RemoteTransportConfiguration _remoteConfiguration;

  RootActor(RemoteTransportConfiguration remoteConfiguration)
      : _remoteConfiguration = remoteConfiguration;
}
