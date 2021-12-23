part of theater.actor;

/// Implementation of [SupervisorStrategy] which applies to all child actors.
///
/// It is used in the event that the work of actors children is closely related to each other and an error in one means that it is necessary to make a decision on what needs to be done with all the actors children.
class AllForOneStrategy extends SupervisorStrategy {
  AllForOneStrategy(
      {required Decider decider,
      //bool loggingEnabled = true,
      bool stopAfterError = true,
      Duration? restartDelay})
      : super(decider, /* loggingEnabled , */ stopAfterError,
            restartDelay: restartDelay);
}
