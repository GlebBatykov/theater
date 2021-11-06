part of theater.actor;

/// The class used by [GroupRouterActor] to communicate with other actors in the actor system.
///
/// Receive messages from other actors, create a group of child actors and control their life cycle.
class GroupRouterActorContext
    extends RouterActorContext<GroupRouterActorProperties> {
  GroupRouterActorContext(
      IsolateContext isolateContext, GroupRouterActorProperties actorProperties)
      : super(isolateContext, actorProperties) {
    _isolateContext.messages.listen(_handleMessageFromSupervisor);

    _messageController.stream.listen(_sendMessageToWorkers);

    _childErrorSubscription = _childErrorController.stream
        .listen((error) => _handleChildError(error));
  }

  @override
  Future<void> _initialize() async {
    await _initializeGroup();
  }

  Future<void> _initializeGroup() async {
    var group = _actorProperties.deployementStrategy.group;

    _childErrorSubscription.pause();

    // Are needed in order to find out if errors came from the created actors during the creation process.
    var errors = <ActorError>[];

    var errorSubscription = _childErrorController.stream.listen((error) {
      errors.add(error);
    });

    for (var i = 0; i < group.length; i++) {
      if (errors.isNotEmpty) {
        await errorSubscription.cancel();
        _childErrorSubscription.resume();
        break;
      }

      var actorPath = path.createChild(group[i].name);

      if (_children.map((e) => e.path).contains(actorPath)) {
        throw ActorContextException(
            message:
                'actor contains child actor with name [' + group[i].name + ']');
      }

      var actorCell = group[i].actor._createActorCellFactory().create(
          actorPath,
          group[i].actor,
          NodeActorCellProperties(
              parentRef: _actorProperties.actorRef, data: group[i].data));

      actorCell.errors.listen((error) => _childErrorController.sink.add(error));

      actorCell.messages.listen(_handleMessageFromActor);

      _children.add(actorCell);

      await actorCell.initialize();

      await actorCell.start();
    }

    await errorSubscription.cancel();
    _childErrorSubscription.resume();
  }

  void _handleMessageFromActor(message) {
    if (message is RoutingMessage) {
      _handleRoutingMessage(message);
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
        var isSended = false;

        for (var child in _children) {
          if (List.from(message.recipientPath.segments
                  .getRange(0, _actorProperties.path.segments.length + 1))
              .equal(child.path.segments)) {
            child.ref.sendMessage(message);
            isSended = true;
            break;
          }
        }

        if (!isSended) {
          message.notFound();
        }
      } else {
        _actorProperties.parentRef.sendMessage(message);
      }
    }
  }

  void _sendMessageToWorkers(MailboxMessage message) {
    var routingStrategy = _actorProperties.deployementStrategy.routingStrategy;

    if (routingStrategy == GroupRoutingStrategy.broadcast) {
      _sendBroadcast(message);
    } else if (routingStrategy == GroupRoutingStrategy.random) {
      _sendRandom(message);
    } else {
      _sendRoundRobin(message);
    }
  }
}
