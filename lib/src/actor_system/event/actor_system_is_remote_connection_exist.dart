part of theater.actor_system;

abstract class ActorSystemIsRemoteConnectionExistResult
    extends ActorSystemEvent {}

class ActorSystemRemoteConnectionExist
    extends ActorSystemIsRemoteConnectionExistResult {}

class ActorSystemRemoteConnectionNotExist
    extends ActorSystemIsRemoteConnectionExistResult {}
