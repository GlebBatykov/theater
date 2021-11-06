part of theater.actor;

abstract class ActorEvent {}

class ActorInitialized extends ActorEvent {
  final SendPort isolateSendPort;

  ActorInitialized(this.isolateSendPort);
}

class ActorStarted extends ActorEvent {}

class ActorPaused extends ActorEvent {}

class ActorKilled extends ActorEvent {}

class ActorResumed extends ActorEvent {}

class ActorReceivedMessage extends ActorEvent {}

class ActorErrorEscalated extends ActorEvent {
  final ActorError error;

  ActorErrorEscalated(this.error);
}

class ActorWantsToDie extends ActorEvent {}
