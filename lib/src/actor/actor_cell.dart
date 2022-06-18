part of theater.actor;

abstract class ActorCell<A extends Actor> {
  final StreamController _messageController = StreamController.broadcast();

  final StreamController<ActorError> _errorController =
      StreamController.broadcast();

  final ActorPath path;

  final SendPort _actorSystemSendPort;

  final Mailbox _mailbox;

  final A _actor;

  late final LocalActorRef ref;

  late final IsolateSupervisor _isolateSupervisor;

  late final LoggingProperties _loggerProperties;

  late final Logger _logger;

  final void Function()? _onKillCallback;

  bool _isDisposed = false;

  Stream get messages => _messageController.stream;

  Stream<ActorError> get errors => _errorController.stream;

  bool get isInitialized => _isolateSupervisor.isInitialized;

  bool get isStarted => _isolateSupervisor.isStarted;

  bool get isPaused => _isolateSupervisor.isPaused;

  bool get isDisposed => _isDisposed;

  ActorCell(this.path, A actor, Mailbox mailbox, SendPort actorSystemSendPort,
      LoggingProperties loggingProperties, void Function()? onKill)
      : _mailbox = mailbox,
        _actor = actor,
        _actorSystemSendPort = actorSystemSendPort,
        _onKillCallback = onKill {
    var actorLoggingProperties = _actor.createLoggingPropeties();

    if (actorLoggingProperties != null) {
      _loggerProperties = actorLoggingProperties;
    } else {
      _loggerProperties = loggingProperties;
    }

    _logger = _loggerProperties.loggerFactory.create(path);
  }

  Future<void> initialize() async {
    await _isolateSupervisor.initialize();

    if (_loggerProperties.isDebugEnabled) {
      _logger
          .debug(ActorLyfecycleLog(ActorLyfecycleLogEvent.initialized, path));
    }
  }

  Future<void> start() async {
    await _isolateSupervisor.start();

    if (_loggerProperties.isDebugEnabled) {
      _logger.debug(ActorLyfecycleLog(ActorLyfecycleLogEvent.started, path));
    }
  }

  Future<void> restart() async {
    await _isolateSupervisor.kill();
    await _isolateSupervisor.initialize();
    await _isolateSupervisor.start();

    if (_loggerProperties.isDebugEnabled) {
      _logger.debug(ActorLyfecycleLog(ActorLyfecycleLogEvent.restarted, path));
    }
  }

  Future<void> pause() async {
    await _isolateSupervisor.pause();

    if (_loggerProperties.isDebugEnabled) {
      _logger.debug(ActorLyfecycleLog(ActorLyfecycleLogEvent.paused, path));
    }
  }

  Future<void> resume() async {
    await _isolateSupervisor.resume();

    if (_loggerProperties.isDebugEnabled) {
      _logger.debug(ActorLyfecycleLog(ActorLyfecycleLogEvent.resumed, path));
    }
  }

  Future<void> kill() async {
    await _isolateSupervisor.kill();

    if (_loggerProperties.isDebugEnabled) {
      _logger.debug(ActorLyfecycleLog(ActorLyfecycleLogEvent.killed, path));
    }

    _onKillCallback?.call();
  }

  Future<void> dispose() async {
    await _isolateSupervisor.dispose();

    await _mailbox.dispose();
    await _messageController.close();
    await _errorController.close();

    _isDisposed = true;

    if (_loggerProperties.isDebugEnabled) {
      _logger.debug(ActorLyfecycleLog(ActorLyfecycleLogEvent.disposed, path));
    }
  }

  @override
  bool operator ==(other) {
    if (other is ActorCell) {
      return path == other.path;
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    var hashCode = super.hashCode;

    return hashCode;
  }
}
