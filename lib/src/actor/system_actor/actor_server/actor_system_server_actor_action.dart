part of theater.actor;

abstract class ActorSystemServerActorAction {}

class ActorSystemServerActorAddRemoteSource
    extends ActorSystemServerActorAction {
  final RemoteSource remoteSource;

  ActorSystemServerActorAddRemoteSource(this.remoteSource);
}
