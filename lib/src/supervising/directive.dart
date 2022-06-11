part of theater.supervising;

/// A directive is a decision made in [SupervisorStrategy] in the process of handling an error coming from the child actor.
///
/// Types of directive:
/// - ignore;
/// - restart;
/// - pause;
/// - kill;
/// - send an error to a supervisor actor (escalate);
/// - remove actor from actor tree (delete).
enum Directive { ignore, restart, pause, kill, escalate, delete }
