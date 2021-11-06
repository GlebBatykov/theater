part of theater.actor;

abstract class ActorIsolateHandler<A extends Actor, C extends ActorContext> {
  final IsolateContext _isolateContext;

  final A _actor;

  final C _actorContext;

  ActorIsolateHandler(IsolateContext isolateContext, A actor, C actorContext)
      : _isolateContext = isolateContext,
        _actor = actor,
        _actorContext = actorContext;

  void start();

  void pause();

  void resume();

  void kill();

  void _handleAction(ActorAction action) {
    if (action is ActorStart) {
      start();
    } else if (action is ActorPause) {
      pause();
    } else if (action is ActorResume) {
      resume();
    } else if (action is ActorKill) {
      kill();
    }
  }
}
