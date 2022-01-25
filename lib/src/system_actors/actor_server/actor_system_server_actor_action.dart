part of theater.system_actors;

abstract class ActorSystemServerActorAction {}

class ActorSystemServerActorAddRemoteSource
    extends ActorSystemServerActorAction {
  final RemoteSource remoteSource;

  ActorSystemServerActorAddRemoteSource(this.remoteSource);
}
