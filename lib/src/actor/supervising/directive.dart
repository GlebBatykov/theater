part of theater.actor.supervising;

/// A directive is a decision made in [SupervisorStrategy] in the process of handling an error coming from the child actor.
///
/// Types of directive:
/// - resume;
/// - restart;
/// - pause;
/// - kill;
/// - send an error to a supervisor actor (escalate).
enum Directive { resume, restart, pause, kill, escalate }
