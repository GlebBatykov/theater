part of theater.actor;

typedef MessageHandler<T> = FutureOr<MessageResult?> Function(T message);

typedef ActorMailboxMessageHandler = FutureOr<void> Function(
    ActorMailboxMessage message);

class HandlerSubscription {
  final void Function() _cancelCallback;

  HandlerSubscription(void Function() cancelCallback)
      : _cancelCallback = cancelCallback;

  void cancel() {
    _cancelCallback();
  }
}

/// This class is a base class for all actor context classes.
abstract class ActorContext<P extends ActorProperties>
    implements ActorMessageSender {
  ///
  final Map<Type, List<ActorMailboxMessageHandler>> _handlers = {};

  /// Instance of [IsolateContext]. Contains ports for communication with isolate supervisor.
  final IsolateContext _isolateContext;

  /// Instance of [ActorProperties]. Contains actor settings for current actor.
  final P _actorProperties;

  ///
  late final LoggingProperties _loggingProperties;

  late final ActorNotifier _notifier;

  /// Instanse of [Scheduler] of this actor context.
  final Scheduler scheduler = Scheduler();

  ///
  late final Logger logger;

  ///
  late final ActorDataStore store;

  /// Path to current actor in actor system.
  ActorPath get path => _actorProperties.path;

  /// The ref that points to the mailbox of the actor to which this context belongs.
  LocalActorRef get self => _actorProperties.actorRef;

  ActorContext._(IsolateContext isolateContext, P actorProperties)
      : _isolateContext = isolateContext,
        _actorProperties = actorProperties {
    store = ActorDataStore(_actorProperties.data);

    _loggingProperties =
        _actorProperties.loggingProperties.actorLoggerProperties ??
            _actorProperties.loggingProperties;

    _notifier = ActorNotifier(_actorProperties.actorSystemSendPort);

    logger = _loggingProperties.loggerFactory.create(path);
  }

  /// Initializes actor context.
  Future<void> _initialize() async {}

  /// Kills current actor and him children.
  void kill() {
    _isolateContext.supervisorMessagePort.send(ActorWantsToDie());
  }

  /// Sends message to actor which in located on [path].
  ///
  /// If [delay] is not null, message sends after delay equals [delay].
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
  @override
  void send(String path, dynamic data, {Duration? delay}) {
    var recipientPath = _parcePath(path);

    var message = ActorRoutingMessage(data, recipientPath);

    if (delay != null) {
      Future.delayed(delay, () {
        _handleRoutingMessage(message);
      });
    } else {
      _handleRoutingMessage(message);
    }
  }

  /// Sends message to actor which in located on [path] and get subscription for this message.
  ///
  /// Use [send] method instead of this methiod if you don't want tracing message status and do not want receive response. Because more message traffic is used to track status and get a response, which degrades throughput.
  ///
  /// If [delay] is not null, message sends after delay equals [delay].
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
  @override
  MessageSubscription sendAndSubscribe(String path, dynamic data,
      {Duration? delay}) {
    var recipientPath = _parcePath(path);

    var receivePort = ReceivePort();

    var message = ActorRoutingMessage(data, recipientPath,
        feedbackPort: receivePort.sendPort);

    if (delay != null) {
      Future.delayed(delay, () {
        _handleRoutingMessage(message);
      });
    } else {
      _handleRoutingMessage(message);
    }

    return MessageSubscription(receivePort);
  }

  /// Sends message with [data] to actor system topic with name [topicName].
  void sendToTopic(String topicName, dynamic data, {Duration? delay}) {
    var action =
        ActorSystemAddTopicMessage(ActorSystemTopicMessage(topicName, data));

    if (delay != null) {
      Future.delayed(delay, () {
        _actorProperties.actorSystemSendPort.send(action);
      });
    } else {
      _actorProperties.actorSystemSendPort.send(action);
    }
  }

  /// Sends message with [data] to actor system topic with name [topicName] and get subscription for this message.
  ///
  ///  Use [sendToTopic] method instead of this methiod if you don't want tracing message status and do not want receive response. Because more message traffic is used to track status and get a response, which degrades throughput.
  MessageSubscription sendToTopicAndSubscribe(String topicName, dynamic data,
      {Duration? delay}) {
    var receivePort = ReceivePort();

    var action = ActorSystemAddTopicMessage(ActorSystemTopicMessage(
        topicName, data,
        feedbackPort: receivePort.sendPort));

    if (delay != null) {
      Future.delayed(delay, () {
        _actorProperties.actorSystemSendPort.send(action);
      });
    } else {
      _actorProperties.actorSystemSendPort.send(action);
    }

    return MessageSubscription(receivePort);
  }

  /// Checks if the register exist a reference to an actor with path - [path].
  ///
  /// If exist return [LocalActorRef] pointing to him.
  ///
  /// If not exist return null.
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
  Future<LocalActorRef?> getLocalActorRef(String path) async {
    var actorPath = _parcePath(path);

    var receivePort = ReceivePort();

    _actorProperties.actorSystemSendPort
        .send(ActorSystemGetUserLocalActorRef(actorPath, receivePort.sendPort));

    var result = await receivePort.first as ActorSystemGetLocalActorRefResult;

    receivePort.close();

    return result.ref;
  }

  /// Checks if the register exist a reference to an actor with path - [path].
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
  Future<bool> isExistLocalActorRef(String path) async {
    var actorPath = _parcePath(path);

    var receivePort = ReceivePort();

    _actorProperties.actorSystemSendPort.send(
        ActorSystemIsExistUserLocalActorRef(actorPath, receivePort.sendPort));

    var result =
        await receivePort.first as ActorSystemIsExistLocalActorRefResult;

    receivePort.close();

    return result.isExist;
  }

  ///
  Future<List<ActorPath>> getActorsPaths() async {
    var receivePort = ReceivePort();

    _actorProperties.actorSystemSendPort
        .send(ActorSystemGetUserActorsPaths(receivePort.sendPort));

    var result = await receivePort.first as ActorSystemGetUserActorsPathsResult;

    receivePort.close();

    return result.paths;
  }

  /// Used for parcing [ActorPath] from path string.
  ActorPath _parcePath(String path) {
    if (ActorPath.isRelativePath(path)) {
      return ActorPath.parceRelative(path, _actorProperties.path);
    } else {
      return ActorPath.parceAbsolute(path);
    }
  }

  /// Handles all routing message passing through the current actor. Including those created by the actor himself using [send].
  void _handleRoutingMessage(RoutingMessage message);

  ///
  void _handleActorMailboxMessage(ActorMailboxMessage message) async {
    var type = message.data.runtimeType;

    var handlers = _handlers[type];

    if (handlers != null) {
      if (_actorProperties.handlingType == HandlingType.consistently) {
        await Future.wait(handlers.map((e) => Future(() async {
              await e(message);
            })));
      } else {
        for (var handler in handlers) {
          handler(message);
        }
      }
    } else {
      if (message.isHaveSubscription) {
        message.feedbackPort!.send(HandlersNotAssignedResult());
      }
    }

    if (_actorProperties.mailboxType == MailboxType.reliable) {
      _isolateContext.supervisorMessagePort.send(ActorReceivedMessage());
    }
  }
}
