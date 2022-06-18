part of theater.system_actors;

abstract class ActorSystemServerCreateServerResult
    extends ActorSystemServerEvent {}

class ActorSystemServerCreateServerSuccess
    extends ActorSystemServerCreateServerResult {}

class ActorSystemServerCreateServerNameExist
    extends ActorSystemServerCreateServerResult {}
