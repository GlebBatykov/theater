part of theater.actor;

mixin ActorParentMixin<P extends SupervisorActorProperties> on ActorContext<P> {
  final List<ActorCell> _children = [];

  final StreamController<ActorError> _childErrorController =
      StreamController.broadcast();

  late final StreamSubscription<ActorError> _childErrorSubscription;

  void _handleChildError(ActorError error) async {
    var actorCell = _findActorCellByPath(error.path);

    var directive = _actorProperties.supervisorStrategy.decide(error.object);

    if (_loggingProperties.isInfoEnabled) {
      logger.info(ActorSupervisingDivideLog(
          _actorProperties.path, actorCell.path, directive, error.object));
    }

    if (directive is RestartDirective) {
      await _restartChild(actorCell, directive);
    } else if (directive is KillDirective) {
      await _killChild(actorCell);
    } else if (directive is EscalateDirective) {
      await _escalateChild(actorCell, error);
    } else if (directive is PauseDirective) {
      await _pauseChild(actorCell);
    } else if (directive is DeleteDirective) {
      await _deleteChild(actorCell);
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

  Future<void> _restartChild(
      ActorCell actorCell, RestartDirective directive) async {
    var restartDelay = directive.delay;

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
    } else {
      await pauseChildren();
    }

    _isolateContext.supervisorMessagePort.send(ActorErrorEscalated(error));
  }

  Future<void> _deleteChild(ActorCell actorCell) async {
    await actorCell.kill();
    await actorCell.dispose();
    _children.remove(actorCell);
  }

  /// Kills child with [path].
  ///
  /// Kills child actor isolate, but does not delete him mailboxe, does not remove child actor from the actor system.
  ///
  /// You can rerun him.
  ///
  /// You have two way how point out path to actor:
  ///
  /// - relative;
  /// - absolute.
  ///
  /// The relative path is set from current actor.
  ///
  /// For example current actor has the name "my_actor", you can point out this path "system/root/user/my_actor/my_child" like "../my_child".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
  Future<void> killChild(String path) async {
    var actorPath = _parcePath(path);

    var actorCell = _findChild(actorPath);

    if (actorCell != null) {
      await actorCell.kill();
    } else {
      throw ActorContextException(
          message:
              'actor has no child with path ' + actorPath.toString() + '.');
    }
  }

  /// Starts child with [path].
  ///
  /// You have two way how point out path to actor:
  ///
  /// - relative;
  /// - absolute.
  ///
  /// The relative path is set from current actor.
  ///
  /// For example current actor has the name "my_actor", you can point out this path "system/root/user/my_actor/my_child" like "../my_child".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
  Future<void> startChild(String path) async {
    var actorPath = _parcePath(path);

    var actorCell = _findChild(actorPath);

    if (actorCell != null) {
      if (!actorCell.isInitialized) {
        await actorCell.initialize();
      }

      await actorCell.start();
    } else {
      throw ActorContextException(
          message:
              'actor has no child with path ' + actorPath.toString() + '.');
    }
  }

  /// Pauses child with [path].
  ///
  /// You have two way how point out path to actor:
  ///
  /// - relative;
  /// - absolute.
  ///
  /// The relative path is set from current actor.
  ///
  /// For example current actor has the name "my_actor", you can point out this path "system/root/user/my_actor/my_child" like "../my_child".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
  Future<void> pauseChild(String path) async {
    var actorPath = _parcePath(path);

    var actorCell = _findChild(actorPath);

    if (actorCell != null) {
      await actorCell.pause();
    } else {
      throw ActorContextException(
          message:
              'actor has no child with path ' + actorPath.toString() + '.');
    }
  }

  /// Resumes child with [path].
  ///
  /// You have two way how point out path to actor:
  ///
  /// - relative;
  /// - absolute.
  ///
  /// The relative path is set from current actor.
  ///
  /// For example current actor has the name "my_actor", you can point out this path "system/root/user/my_actor/my_child" like "../my_child".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
  Future<void> resumeChild(String path) async {
    var actorPath = _parcePath(path);

    var actorCell = _findChild(actorPath);

    if (actorCell != null) {
      await actorCell.resume();
    } else {
      throw ActorContextException(
          message:
              'actor has no child with path ' + actorPath.toString() + '.');
    }
  }

  /// Restarts child with [path].
  ///
  /// You have two way how point out path to actor:
  ///
  /// - relative;
  /// - absolute.
  ///
  /// The relative path is set from current actor.
  ///
  /// For example current actor has the name "my_actor", you can point out this path "system/root/user/my_actor/my_child" like "../my_child".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
  Future<void> restartChild(String path) async {
    var actorPath = _parcePath(path);

    var actorCell = _findChild(actorPath);

    if (actorCell != null) {
      await actorCell.kill();
    } else {
      throw ActorContextException(
          message:
              'actor has no child with path ' + actorPath.toString() + '.');
    }
  }

  /// Deletes child with [path].
  ///
  /// Kills the actor, as well as clears and deletes his mailbox. Deletes an actor from the actor system.
  ///
  /// You have two way how point out path to actor:
  ///
  /// - relative;
  /// - absolute.
  ///
  /// The relative path is set from current actor.
  ///
  /// For example current actor has the name "my_actor", you can point out this path "system/root/user/my_actor/my_child" like "../my_child".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
  Future<void> deleteChild(String path) async {
    var actorPath = _parcePath(path);

    var actorCell = _findChild(actorPath);

    if (actorCell != null) {
      await _deleteChild(actorCell);
    } else {
      throw ActorContextException(
          message:
              'actor has no child with path ' + actorPath.toString() + '.');
    }
  }

  ActorCell? _findChild(ActorPath path) {
    for (var child in _children) {
      if (child.path == path) {
        return child;
      }
    }

    return null;
  }

  /// Kills all actor children.
  ///
  /// Kills child actors isolate, but does not delete their mailboxes, does not remove actors from the actor system.
  ///
  /// You can rerun them.
  Future<void> killChildren() async {
    for (var child in _children) {
      await child.kill();
    }
  }

  /// Starts all actor childern.
  Future<void> startChildren() async {
    for (var child in _children) {
      await child.start();
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

  /// Kills all actor children and deletes them from actor tree.
  ///
  /// Kills child actors and cleans and deletes their mailboxes. Deletes child actors from the actor system.
  Future<void> deleteChildren() async {
    for (var child in _children) {
      await _deleteChild(child);
    }
  }
}
