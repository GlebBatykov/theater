part of theater.actor;

abstract class ActorCell<A extends Actor> {
  final StreamController _messageController = StreamController.broadcast();

  final StreamController<ActorError> _errorController =
      StreamController.broadcast();

  final ActorPath path;

  final SendPort _actorSystemMessagePort;

  final Mailbox _mailbox;

  final A _actor;

  late final LocalActorRef ref;

  late final IsolateSupervisor _isolateSupervisor;

  final void Function()? _onKillCallback;

  bool _isDisposed = false;

  Stream get messages => _messageController.stream;

  Stream<ActorError> get errors => _errorController.stream;

  bool get isInitialized => _isolateSupervisor.isInitialized;

  bool get isStarted => _isolateSupervisor.isStarted;

  bool get isPaused => _isolateSupervisor.isPaused;

  bool get isDisposed => _isDisposed;

  ActorCell(this.path, A actor, Mailbox mailbox,
      SendPort actorSystemMessagePort, void Function()? onKill)
      : _mailbox = mailbox,
        _actor = actor,
        _actorSystemMessagePort = actorSystemMessagePort,
        _onKillCallback = onKill;

  Future<void> initialize() async {
    await _isolateSupervisor.initialize();
  }

  Future<void> start() async {
    await _isolateSupervisor.start();
  }

  Future<void> restart() async {
    await _isolateSupervisor.kill();
    await _isolateSupervisor.initialize();
    await _isolateSupervisor.start();
  }

  Future<void> pause() async {
    await _isolateSupervisor.pause();
  }

  Future<void> resume() async {
    await _isolateSupervisor.resume();
  }

  Future<void> kill() async {
    await _isolateSupervisor.kill();

    _onKillCallback?.call();
  }

  Future<void> dispose() async {
    await _isolateSupervisor.dispose();

    await _mailbox.dispose();
    await _messageController.close();
    await _errorController.close();

    _isDisposed = true;
  }

  @override
  bool operator ==(other) {
    if (other is ActorCell) {
      return path == other.path;
    } else {
      return false;
    }
  }
}
