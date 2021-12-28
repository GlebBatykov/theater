part of theater.actor;

class IsolateSupervisor {
  final StreamController _messageController = StreamController.broadcast();

  final StreamController<IsolateError> _errorController =
      StreamController.broadcast();

  final StreamController<ActorEvent> _eventController =
      StreamController.broadcast();

  Isolate? _isolate;

  final ReceivePort _receivePort = ReceivePort();

  final ReceivePort _errorReceivePort = ReceivePort();

  late final Stream _receiveStream;

  SendPort? _isolateSendPort;

  final Queue _messageQueue = Queue();

  final Actor _actor;

  final ActorProperties _actorProperties;

  final ActorIsolateHandlerFactory _isolateHandlerFactory;

  final ActorContextFactory _contextFactory;

  final Map<String, dynamic> _data;

  final void Function()? _onKill;

  bool _isStarted = false;

  bool _isInitialized = false;

  bool _isPaused = false;

  bool _isDisposed = false;

  Capability? _resumeCapability;

  bool get isStarted => _isStarted;

  bool get isInitialized => _isInitialized;

  bool get isPaused => _isPaused;

  bool get isDisposed => _isDisposed;

  Stream<IsolateError> get errors => _errorController.stream;

  Stream<dynamic> get messages => _messageController.stream;

  IsolateSupervisor(
      Actor actor,
      ActorProperties actorProperties,
      ActorIsolateHandlerFactory isolateHandlerFactory,
      ActorContextFactory contextFactory,
      {Map<String, dynamic>? data,
      void Function(IsolateError)? onError,
      void Function()? onKill})
      : _actor = actor,
        _actorProperties = actorProperties,
        _isolateHandlerFactory = isolateHandlerFactory,
        _contextFactory = contextFactory,
        _data = data ?? {},
        _onKill = onKill {
    if (onError != null) {
      _errorController.stream.listen(onError);
    }

    _receiveStream = _receivePort.asBroadcastStream();

    _receiveStream.listen((message) => _handleMessage(message));

    _errorReceivePort.listen((message) {
      if (message is IsolateError) {
        _errorController.sink.add(message);
      }
    });

    _eventController.stream.listen((event) {
      if (event is ActorReceivedMessage) {
        _messageController.sink.add(event);
      } else if (event is ActorErrorEscalated) {
        _messageController.sink.add(ActorErrorEscalated(event.error));
      } else if (event is ActorCompletedTask) {
        _messageController.sink.add(event);
      } else if (event is ActorWantsToDie) {
        kill();
      }
    });
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      var spawnMessage = IsolateSpawnMessage(
          _receivePort.sendPort,
          _errorReceivePort.sendPort,
          _actor,
          _actorProperties,
          _isolateHandlerFactory,
          _contextFactory,
          _data);

      _isolate = await Isolate.spawn(_isolateEntryPoint, spawnMessage,
          errorsAreFatal: false);

      var event = await _eventController.stream
              .firstWhere((element) => element is ActorInitialized)
          as ActorInitialized;

      _isolateSendPort = event.isolateSendPort;
      _isInitialized = true;
      _sendMessageQueue();
    }
  }

  Future<void> start({void Function()? onError}) async {
    if (!_isStarted) {
      _isolateSendPort!.send(ActorStart());

      await _eventController.stream
          .firstWhere((element) => element is ActorStarted);

      _isStarted = true;
    }
  }

  void _handleMessage(dynamic message) {
    if (message is RoutingMessage) {
      _messageController.sink.add(message);
    } else if (message is ActorEvent) {
      _eventController.sink.add(message);
    }
  }

  static void _isolateEntryPoint(IsolateSpawnMessage message) {
    runZonedGuarded(() async {
      var receivePort = ReceivePort();

      var isolateContext = IsolateContext(receivePort,
          message.supervisorMessagePort, message.supervisorErrorPort);

      var actorContext = message.contextFactory
          .create(isolateContext, message.actorProperties);

      message.isolateHandlerFactory
          .create(isolateContext, message.actor, actorContext);

      try {
        await actorContext._initialize();
      } catch (_) {
        rethrow;
      } finally {
        message.supervisorMessagePort
            .send(ActorInitialized(receivePort.sendPort));
      }
    }, (exception, stackTrace) {
      message.supervisorErrorPort
          .send(IsolateError(exception as Exception, stackTrace));
    });
  }

  Future<void> pause() async {
    if (_isolate != null && _isInitialized && !_isPaused) {
      _isolateSendPort!.send(ActorPause());

      await _eventController.stream
          .firstWhere((element) => element is ActorPaused);

      _resumeCapability = _isolate!.pause(_isolate!.pauseCapability);

      _isPaused = true;
    }
  }

  Future<void> resume() async {
    if (_isolate != null && _isPaused) {
      _isolate!.resume(_resumeCapability!);

      _isolateSendPort!.send(ActorResume());

      await _eventController.stream
          .firstWhere((element) => element is ActorResumed);

      _isPaused = false;
    }
  }

  Future<void> kill() async {
    if (_isInitialized) {
      if (_isPaused) {
        await resume();
      }

      _isolateSendPort!.send(ActorKill());

      await _eventController.stream
          .firstWhere((element) => element is ActorKilled);

      _onKill?.call();

      _isolate?.kill(priority: Isolate.immediate);

      _isolate = null;

      _isStarted = false;
      _isInitialized = false;
      _isPaused = false;
    }
  }

  /// Dispoces all resource, streams for [IsolateSupervisor]. After dispoce you can't use listening for [IsolateSupervisor] messages.
  Future<void> dispose() async {
    await kill();

    _receivePort.close();
    _errorReceivePort.close();

    await _messageController.close();
    await _errorController.close();
    await _eventController.close();

    _messageQueue.clear();

    _isDisposed = true;
  }

  /// Sends message to [Isolate] in [IsolateSupervisor].
  void send(message) {
    if (_isInitialized) {
      _isolateSendPort?.send(message);
    } else {
      _messageQueue.add(message);
    }
  }

  /// Sends all [IsolateMessage] messages in [_messageQueue] to isolate
  void _sendMessageQueue() {
    while (_messageQueue.isNotEmpty) {
      var message = _messageQueue.removeFirst();

      send(message);
    }
  }
}
