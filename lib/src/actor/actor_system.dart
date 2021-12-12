part of theater.actor;

/// Class is used for creating group of actor.
///
/// Group of actor which is created by the [ActorSystem] is represented as a tree.
///
/// Each actor which located in a separate [Isolate]. Has its own memory area.
///
/// [ActorSystem] helps executing code in another thread (in another [Isolate]), without delving into work [ReceivePort] and [SendPort].
///
/// [ActorSystem] allows you to conveniently send messages between actors. Each actor in the actor system has its own [ActorPath].
///
/// In addition to the actors created by the user, the [ActorSystem] during initialization creates the actors that are necessary for its work.
///
/// An example of such system actors:
///
/// - [RootActor] is the root actor, the first actor created by the [ActorSystem] on initialization. The only one actor who don't have parent.
///
/// - [UserGuardian] is the actor who is the parent of all user-created actors. Created by the [RootActor] upon start.
///
/// - [SystemGuardian] is the actor who is the parent of all system actors. Created by the [RootActor] upon start.
class ActorSystem implements ActorRefFactory<NodeActor>, ActorMessageSender {
  /// Name of actor system. Used in [ActorPath] of everyone actors.
  final String name;

  /// Instanse of [ReceivePort] of actor system.
  late ReceivePort _messagePort;

  final StreamController<ActorSystemTopicMessage> _topicMessageController =
      StreamController.broadcast();

  /// [ActorPath] instance of [RootActor] actor.
  late final ActorPath _rootPath;

  /// [ActorPath] instance of [UserGuardian] actor.
  late final ActorPath _userGuardianPath;

  /// [ActorPath] instance of [SystemGuardian] actor.
  // ignore: unused_field
  late final ActorPath _systemGuardianPath;

  /// [RootActorCell] instance of root actor.
  late final RootActorCell _root;

  /// Contains all top-level actor names.
  final List<String> _topLevelActorNames = [];

  bool _isDisposed = false;

  /// Shows the status of dispose.
  bool get isDisposed => _isDisposed;

  /// Used in creation top-level actors, needs for receive response from [UserGuardian].
  ///
  /// If [ActorSystem] call [dispose] method and in this time some top-level actor is in the making - closes all port.
  final List<ReceivePort> _createChildReceivePorts = [];

  ActorSystem(this.name,
      {ServerConfiguration serverConfiguration =
          ServerConfiguration.defaultConfiguration}) {
    _rootPath = ActorPath(Address(name), 'root', 0);

    _userGuardianPath = _rootPath.createChild('user');

    _systemGuardianPath = _rootPath.createChild('system');
  }

  /// Uses by the primary initialization [ActorSystem]. Creates and starts root actor and guardians, system actors.
  ///
  /// Before work with actor system you must initialize it.
  Future<void> initialize() async {
    _messagePort = ReceivePort();

    _messagePort.listen((message) {
      if (message is ActorSystemTopicMessage) {
        _topicMessageController.sink.add(message);
      }
    });

    _root = RootActorCell(_rootPath, DefaultRootActor(), _messagePort.sendPort);

    // If root actor escalate error. Prints stackTrace and dispose actor system.
    _root.errors.listen((error) {
      dispose();

      throw ActorSystemException(
          message: 'in actor system unhandled exception occurred.\n\n' +
              error.toString());
    });

    await _root.initialize();

    await _root.start();
  }

  /// Pauses all actors in actor system.
  Future<void> pause() async {
    await _root.pause();
  }

  /// Resumes all actors in actor system.
  Future<void> resume() async {
    await _root.resume();
  }

  /// Kills all actors in actor system.
  Future<void> kill() async {
    await _root.kill();
  }

  /// Creates new top-level actor in [ActorSystem] and returns [LocalActorRef] pointing to his [Mailbox].
  ///
  /// Names of actor should not be repeated.
  @override
  Future<LocalActorRef> actorOf<T extends NodeActor>(String name, T actor,
      {Map<String, dynamic>? data, void Function()? onKill}) async {
    if (_root.isInitialized) {
      if (_topLevelActorNames.contains(name)) {
        throw ActorSystemException(
            message:
                'actor system contains top level actor with name [$name].');
      }

      var receivePort = ReceivePort();

      _createChildReceivePorts.add(receivePort);

      var action = UserGuardianCreateTopLevelActor(name, actor, data, onKill);

      _root.ref.sendMessage(SystemRoutingMessage(action, _userGuardianPath,
          feedbackPort: receivePort.sendPort));

      late LocalActorRef actorRef;

      await for (var message in receivePort) {
        if (message is MessageResult) {
          actorRef = message.data;
          break;
        }
      }

      receivePort.close();

      return actorRef;
    } else {
      throw ActorSystemException(message: 'actor system is not initialized.');
    }
  }

  ///
  @override
  void send(String path, dynamic data, {Duration? delay}) {
    var recipientPath = _parcePath(path);

    if (delay != null) {
      Future.delayed(delay, () {
        _root.ref.sendMessage(ActorRoutingMessage(data, recipientPath));
      });
    } else {
      _root.ref.sendMessage(ActorRoutingMessage(data, recipientPath));
    }
  }

  /// Sends message to actor which in located on [path].
  ///
  /// If [duration] is not null, message sends after delay equals [duration].
  ///
  /// You have two way how point out path to actor:
  ///
  /// - relative;
  /// - absolute.
  ///
  /// The relative path is set from [UserGuardian].
  ///
  /// For example, you can point out this path "system/root/user/my_actor" like "../my_actor".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
  @override
  MessageSubscription sendAndSubscribe(String path, dynamic data,
      {Duration? delay}) {
    var recipientPath = _parcePath(path);

    var receivePort = ReceivePort();

    if (delay != null) {
      Future.delayed(delay, () {
        _root.ref.sendMessage(ActorRoutingMessage(data, recipientPath,
            feedbackPort: receivePort.sendPort));
      });
    } else {
      _root.ref.sendMessage(ActorRoutingMessage(data, recipientPath,
          feedbackPort: receivePort.sendPort));
    }

    return MessageSubscription(receivePort);
  }

  /// Used for parcing [ActorPath] from path string.
  ActorPath _parcePath(String path) {
    if (ActorPath.isRelativePath(path)) {
      return ActorPath.parceRelative(path, _userGuardianPath);
    } else {
      return ActorPath.parceAbsolute(path);
    }
  }

  /// Create handler to topic with name [topicName] and his messages are [T].
  StreamSubscription<ActorSystemTopicMessage> listenTopic<T>(
      String topicName, Future<MessageResult?> Function(T) handler) {
    var subscription = _topicMessageController.stream.listen((message) async {
      if (message.topicName == topicName && message.data is T) {
        var result = await handler(message.data);

        if (message.isHaveSubscription) {
          result != null ? message.sendResult(result) : message.successful();
        }
      }
    });

    return subscription;
  }

  /// Kills all actors in actor system and frees all resources, close all streams that were used by the actor system.
  Future<void> dispose() async {
    await _root.dispose();

    await _topicMessageController.close();

    _messagePort.close();

    for (var port in _createChildReceivePorts) {
      port.close();
    }

    _isDisposed = true;
  }
}
