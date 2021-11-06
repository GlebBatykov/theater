part of theater.actor;

mixin ActorParent<P extends SupervisorActorProperties> on ActorContext<P> {
  final List<ActorCell> _children = [];

  final StreamController<ActorError> _childErrorController =
      StreamController.broadcast();

  late final StreamSubscription<ActorError> _childErrorSubscription;

  void _handleChildError(ActorError error) async {
    var actorCell = _findActorCellByPath(error.path);

    if (_actorProperties.supervisorStrategy.stopAfterError) {
      await actorCell.pause();
    }

    var directive = _actorProperties.supervisorStrategy.decide(error.exception);

    if (directive == Directive.restart) {
      await _restartChild(actorCell);
    } else if (directive == Directive.kill) {
      await _killChild(actorCell);
    } else if (directive == Directive.escalate) {
      await _escalateChild(actorCell, error);
    } else if (directive == Directive.resume) {
      await _resumeChild(actorCell);
    } else if (directive == Directive.pause) {
      await _pauseChild(actorCell);
    }
  }

  ActorCell _findActorCellByPath(ActorPath path) {
    late ActorCell actorCell;

    for (var child in _children) {
      if (child.path == path) {
        actorCell = child;
        break;
      }
    }

    return actorCell;
  }

  Future<void> _resumeChild(ActorCell actorCell) async {
    if (_actorProperties.supervisorStrategy is OneForOneStrategy) {
      await actorCell.resume();
    } else {
      await resumeChildren();
    }

    //if (_actorProperties.supervisorStrategy.loggingEnabled) {}
  }

  Future<void> _restartChild(ActorCell actorCell) async {
    var restartDelay = _actorProperties.supervisorStrategy.restartDelay;

    if (_actorProperties.supervisorStrategy is OneForOneStrategy) {
      if (restartDelay != null) {
        await Future.delayed(restartDelay, () async {
          await actorCell.restart();
        });
      } else {
        await actorCell.restart();
      }
    } else {
      if (restartDelay != null) {
        await Future.delayed(restartDelay, () async {
          await restartChildren();
        });
      } else {
        await restartChildren();
      }
    }

    //if (_actorProperties.supervisorStrategy.loggingEnabled) {}
  }

  Future<void> _pauseChild(ActorCell actorCell) async {
    if (_actorProperties.supervisorStrategy is OneForOneStrategy) {
      await actorCell.pause();
    } else {
      await pauseChildren();
    }

    //if (_actorProperties.supervisorStrategy.loggingEnabled) {}
  }

  Future<void> _killChild(ActorCell actorCell) async {
    if (_actorProperties.supervisorStrategy is OneForOneStrategy) {
      await actorCell.kill();
    } else {
      await killChildren();
    }

    //if (_actorProperties.supervisorStrategy.loggingEnabled) {}
  }

  Future<void> _escalateChild(ActorCell actorCell, ActorError error) async {
    //if (_actorProperties.supervisorStrategy.loggingEnabled) {}

    if (_actorProperties.supervisorStrategy is OneForOneStrategy) {
      await actorCell.pause();
    } else {}

    _isolateContext.supervisorMessagePort.send(ActorErrorEscalated(error));
  }

  /// Kills all actor children.
  Future<void> killChildren() async {
    for (var child in _children) {
      await child.kill();
    }
  }

  /// Pauses all actor children.
  Future<void> pauseChildren() async {
    for (var child in _children) {
      await child.pause();
    }
  }

  /// Resume all actors children.
  Future<void> resumeChildren() async {
    for (var child in _children) {
      await child.resume();
    }
  }

  /// Restart all actor children.
  Future<void> restartChildren() async {
    for (var child in _children) {
      await child.restart();
    }
  }
}
