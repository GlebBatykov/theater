part of theater.logging;

class ActorSupervisingDivideLog {
  final ActorPath actorPath;

  final ActorPath childPath;

  final Directive directive;

  final Object error;

  ActorSupervisingDivideLog(
      this.actorPath, this.childPath, this.directive, this.error);

  @override
  String toString() {
    return 'Actor name: [${actorPath.name}], actor path: [$actorPath]. Child name: [${childPath.name}], child path: [$childPath]. Error: [${error.runtimeType}], divide directive: [${directive.name}].';
  }
}
