part of theater.supervising;

/// The class used by [SupervisorStrategy] to decide what to do with the happened exceptions or errors.
abstract class Decider {
  /// Decides which directive to return depending on exception or error.
  Directive decide(Object object);
}
