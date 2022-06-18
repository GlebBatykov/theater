part of theater.supervising;

/// Implementation of [SupervisorStrategy] which applies to one specific child actor in which the error occurred.
class OneForOneStrategy extends SupervisorStrategy {
  OneForOneStrategy({required Decider decider}) : super(decider);
}
