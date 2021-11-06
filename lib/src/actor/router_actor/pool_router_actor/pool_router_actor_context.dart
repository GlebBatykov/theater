part of theater.actor;

/// The class used by [PoolRouterActor] to communicate with other actors in the actor system.
///
/// Receive messages from other actors, create a pool of child actors and control their life cycle.
class PoolRouterActorContext
    extends RouterActorContext<PoolRouterActorProperties> {
  final Map<ActorCell, int> _loadingMap = {};

  PoolRouterActorContext(
      IsolateContext isolateContext, PoolRouterActorProperties actorProperties)
      : super(isolateContext, actorProperties) {
    _isolateContext.messages.listen(_handleMessageFromSupervisor);

    _messageController.stream.listen(_sendMessageToWorkers);

    _childErrorSubscription = _childErrorController.stream
        .listen((error) => _handleChildError(error));
  }

  @override
  Future<void> _initialize() async {
    await _initializePool();
  }

  Future<void> _initializePool() async {
    var actor = _actorProperties.deployementStrategy.workerFactory.create();

    var actorCellFactory = actor._createActorCellFactory();

    _childErrorSubscription.pause();

    var errors = <ActorError>[];

    var errorSubscription = _childErrorController.stream.listen((error) {
      errors.add(error);
    });

    for (var i = 0; i < _actorProperties.deployementStrategy.poolSize; i++) {
      if (errors.isNotEmpty) {
        await errorSubscription.cancel();
        _childErrorSubscription.resume();
        break;
      }

      var actorPath = path.createChild('worker-' + (i + 1).toString());

      var actorCell = actorCellFactory.create(
          actorPath,
          actor,
          WorkerActorCellProperties(
              parentRef: _actorProperties.actorRef,
              data: _actorProperties.deployementStrategy.data));

      actorCell.errors.listen((error) => _childErrorController.sink.add(error));

      actorCell.messages.listen(_handleMessageFromActor);

      _children.add(actorCell);

      await actorCell.initialize();

      await actorCell.start();

      _loadingMap[actorCell] = 0;
    }

    await errorSubscription.cancel();
    _childErrorSubscription.resume();
  }

  void _handleMessageFromActor(message) {
    if (message is RoutingMessage) {
      _handleRoutingMessage(message);
    } else if (message is ActorCompletedTask) {
      for (var entry in _loadingMap.entries) {
        if (entry.key.path == message.workerPath) {
          _loadingMap[entry.key] = _loadingMap[entry.key]! - 1;
        }
      }
    }
  }

  void _handleMessageFromSupervisor(ActorMessage message) {
    if (message is MailboxMessage) {
      _handleMailboxMessage(message);
    } else if (message is RoutingMessage) {
      _handleRoutingMessage(message);
    }
  }

  void _handleMailboxMessage(MailboxMessage message) {
    _messageController.sink.add(message);

    if (_actorProperties.mailboxType == MailboxType.reliable) {
      _isolateContext.supervisorMessagePort.send(ActorReceivedMessage());
    }
  }

  void _sendMessageToWorkers(MailboxMessage message) {
    var routingStrategy = _actorProperties.deployementStrategy.routingStrategy;

    if (routingStrategy == PoolRoutingStrategy.broadcast) {
      _sendBroadcast(message);
    } else if (routingStrategy == PoolRoutingStrategy.random) {
      _sendRandom(message);
    } else if (routingStrategy == PoolRoutingStrategy.roundRobin) {
      _sendRoundRobin(message);
    } else {
      _sendBalancing(message);
    }
  }

  void _sendBalancing(MailboxMessage message) {
    var minimal = _loadingMap.entries.first;

    for (var worker in _loadingMap.entries) {
      if (worker.key != minimal.key && worker.value < minimal.value) {
        minimal = worker;
      }
    }

    minimal.key.ref.sendMessage(message);

    _loadingMap[minimal.key] = _loadingMap[minimal.key]! + 1;
  }

  @override
  void _handleRoutingMessage(RoutingMessage message) {
    if (message.recipientPath == _actorProperties.path) {
      _actorProperties.actorRef
          .sendMessage(MailboxMessage(message.data, message.feedbackPort));
    } else {
      if (message.recipientPath.depthLevel > _actorProperties.path.depthLevel &&
          List.of(message.recipientPath.segments
                  .getRange(0, _actorProperties.path.segments.length))
              .equal(_actorProperties.path.segments)) {
        message.notFound();
      } else {
        _actorProperties.parentRef.sendMessage(message);
      }
    }
  }
}
