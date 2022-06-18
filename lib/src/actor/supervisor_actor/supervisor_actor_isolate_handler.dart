part of theater.actor;

abstract class SupervisorActorIsolateHandler<A extends SupervisorActor,
    C extends SupervisorActorContext> extends ActorIsolateHandler<A, C> {
  SupervisorActorIsolateHandler(
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
      await _actorContext.pauseChildren();

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

      await _actorContext.resumeChildren();
    } catch (_) {
      rethrow;
    } finally {
      _isolateContext.supervisorMessagePort.send(ActorResumed());
    }
  }

  @override
  void kill() async {
    try {
      await _actorContext.killChildren();

      await _actor.onKill(_actorContext);

      await _actorContext._notifier.dispose();
    } catch (_) {
      rethrow;
    } finally {
      _isolateContext.supervisorMessagePort.send(ActorKilled());
    }
  }
}
