part of theater.actor;

abstract class ObservableActorIsolateHandler<A extends ObservableActor,
    C extends ObservableActorContext> extends ActorIsolateHandler<A, C> {
  ObservableActorIsolateHandler(
      IsolateContext isolateContext, A actor, C actorContext)
      : super(isolateContext, actor, actorContext);

  @override
  void start() async {
    try {
      await _actor.onStart(_actorContext);
    } catch (_) {
      rethrow;
    } finally {
      _isolateContext.supervisorMessagePort.send(ActorStarted());
    }
  }

  @override
  void pause() async {
    try {
      await _actor.onPause(_actorContext);
    } catch (_) {
      rethrow;
    } finally {
      _isolateContext.supervisorMessagePort.send(ActorPaused());
    }
  }

  @override
  void resume() async {
    try {
      await _actor.onResume(_actorContext);
    } catch (_) {
      rethrow;
    } finally {
      _isolateContext.supervisorMessagePort.send(ActorResumed());
    }
  }

  @override
  void kill() async {
    try {
      await _actor.onKill(_actorContext);

      await _actorContext._notifier.dispose();
    } catch (_) {
      rethrow;
    } finally {
      _isolateContext.supervisorMessagePort.send(ActorKilled());
    }
  }
}
