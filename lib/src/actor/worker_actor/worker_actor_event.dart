part of theater.actor;

abstract class WorkerActorEvent extends ActorEvent {}

class ActorCompletedTask extends WorkerActorEvent {
  final ActorPath workerPath;

  ActorCompletedTask(this.workerPath);
}
