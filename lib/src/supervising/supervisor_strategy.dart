part of theater.supervising;

/// Class is a base class to all supervisor strategy classes like [OneForOneStrategy], [AllForOneStrategy].
///
/// Supervisor strategy is used in the supervisor by actors to handle child actor errors.
abstract class SupervisorStrategy {
  /// Decider used by supervisor strategy for decide for the exception that has occurred.
  final Decider _decider;

  /// Delay before the child actor is restarted.
  final Duration? restartDelay;

  //final bool loggingEnabled;

  /// Determines whether the child actor should be stopped after an error has occurred in it, before a decision is made on how to handle the error.
  final bool stopAfterError;

  SupervisorStrategy(
      Decider decider, /* this.loggingEnabled, */ this.stopAfterError,
      {this.restartDelay})
      : _decider = decider;

  /// Decides which directive to return depending on [exception].
  Directive decide(Exception exception) => _decider.decide(exception);
}
