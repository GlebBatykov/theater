part of theater.actor_system;

abstract class ActorSystemCreateServerResult extends ActorSystemEvent {}

class ActorSystemCreateServerSuccess extends ActorSystemCreateServerResult {}

class ActorSystemCreateServerNameExist extends ActorSystemCreateServerResult {}
