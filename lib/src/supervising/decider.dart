part of theater.supervising;

/// The class used by [SupervisorStrategy] to decide what to do with the happened exception.
abstract class Decider {
  /// Decides which directive to return depending on [exception].
  Directive decide(Exception exception);
}
