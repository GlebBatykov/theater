part of theater.actor.supervising;

/// Implementation of [SupervisorStrategy] which applies to one specific child actor in which the error occurred.
class OneForOneStrategy extends SupervisorStrategy {
  OneForOneStrategy(
      {required Decider decider,
      //bool loggingEnabled = true,
      bool stopAfterError = true,
      Duration? restartDelay})
      : super(decider, /* loggingEnabled, */ stopAfterError,
            restartDelay: restartDelay);
}
