part of theater.logging;

class ActorLyfecycleLog {
  final ActorLyfecycleLogEvent event;

  final ActorPath actorPath;

  ActorLyfecycleLog(this.event, this.actorPath);

  @override
  String toString() {
    return 'Actor name: [${actorPath.name}], actor path: [$actorPath], was ${event.name}.';
  }
}
