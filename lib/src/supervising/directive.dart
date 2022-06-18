part of theater.supervising;

/// Base class for all directive.
///
/// A directive is a decision made in [SupervisorStrategy] in the process of handling an error coming from the child actor.
///
/// Types of directive:
/// - ignore;
/// - restart;
/// - pause;
/// - kill;
/// - send an error to a supervisor actor (escalate);
/// - remove actor from actor tree (delete).
abstract class Directive {
  final String name;

  Directive(this.name);
}

class IgnoreDirective extends Directive {
  IgnoreDirective() : super('ignore');
}

class RestartDirective extends Directive {
  final Duration? delay;

  RestartDirective({this.delay}) : super('restart');
}

class PauseDirective extends Directive {
  PauseDirective() : super('pause');
}

class KillDirective extends Directive {
  KillDirective() : super('kill');
}

class EscalateDirective extends Directive {
  EscalateDirective() : super('escalate');
}

class DeleteDirective extends Directive {
  DeleteDirective() : super('delete');
}
