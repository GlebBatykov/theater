part of theater.actor;

/// This class is a base class for actors who can create child actors and take on the role of supervisor for children.
abstract class SupervisorActor<T extends SupervisorActorContext>
    extends Actor<T> {}
