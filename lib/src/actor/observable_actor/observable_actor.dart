part of theater.actor;

/// This class is a base class for actors who can't create child actors.
abstract class ObservableActor<T extends ObservableActorContext>
    extends Actor<T> {}
