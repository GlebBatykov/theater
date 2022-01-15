part of theater.actor_system;

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

  /// Instance of [RemoteTransportConfiguration] which used for configuration actor system server.
  final RemoteTransportConfiguration _remoteConfiguration;

  ///
  final List<RemoteSource> _remoteSources = [];

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

  /// [LocalActorRef] instance pointing to mailbox of user guardian.
  late LocalActorRef _userGuardianRef;

  /// [RootActorCell] instance of root actor.
  late final RootActorCell _root;

  /// Contains all top-level actor names.
  final List<String> _topLevelActorNames = [];

  /// Instance of [LocalActorRefRegister] used to store links to user actors.
  final LocalActorRefRegister _userActorRegister = LocalActorRefRegister();

  /// Instance of [LocalActorRefRegister] used to store links to system actors.
  final LocalActorRefRegister _systemActorRegister = LocalActorRefRegister();

  bool _isDisposed = false;

  /// Used in creation top-level actors, needs for receive response from [UserGuardian].
  ///
  /// If [ActorSystem] call [dispose] method and in this time some top-level actor is in the making - closes all port.
  final List<ReceivePort> _createChildReceivePorts = [];

  /// Shows the status of dispose.
  bool get isDisposed => _isDisposed;

  ActorSystem(this.name, {RemoteTransportConfiguration? remoteConfiguration})
      : _remoteConfiguration = remoteConfiguration ??
            RemoteTransportConfiguration(isRemoteTransportEnabled: false) {
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
      } else if (message is ActorSystemAction) {
        _handleActorSystemAction(message);
      }
    });

    _root = RootActorCell(
        _rootPath,
        DefaultRootActor(remoteConfiguration: _remoteConfiguration),
        _messagePort.sendPort);

    // If root actor escalate error. Prints stackTrace and dispose actor system.
    _root.errors.listen((error) {
      dispose();

      throw ActorSystemException(
          message: 'in actor system unhandled exception occurred.\n\n' +
              error.toString());
    });

    await _root.initialize();

    await _root.start();

    _userGuardianRef = _systemActorRegister.getRefByPath(_userGuardianPath)!;
  }

  void _handleActorSystemAction(ActorSystemAction action) {
    if (action is ActorSystemRegisterLocalActorRef) {
      _handleActorSystemRegisterLocalActorRefAction(action);
    } else if (action is ActorSystemRemoveLocalActorRef) {
      _handleActorSystemRemoveLocalActorRefAction(action);
    } else if (action is ActorSystemGetLocalActorRef) {
      _handleActorSystemGetLocalActorRefAction(action);
    } else if (action is ActorSystemIsExistLocalActorRef) {
      _handleActorSystemIsExistLocalActorRef(action);
    } else if (action is ActorSystemAddTopicMessage) {
      _handleActorSystemAddTopicMessage(action);
    } else if (action is ActorSystemSetRemoteSources) {
      _handleActorSystemSetRemoteSources(action);
    } else if (action is ActorSystemCreateRemoteActorRef) {
      _handleActorSystemCreateRemoteActorRef(action);
    } else if (action is ActorSystemRouteActorRemoteMessage) {
      _handleActorSystemRouteActorRemoteMessage(action);
    }
  }

  void _handleActorSystemRegisterLocalActorRefAction(
      ActorSystemRegisterLocalActorRef action) {
    if (action is ActorSystemRegisterUserLocalActorRef) {
      _userActorRegister.registerRef(action.ref);
    } else if (action is ActorSystemRegisterSystemLocalActorRef) {
      _systemActorRegister.registerRef(action.ref);
    }
  }

  void _handleActorSystemRemoveLocalActorRefAction(
      ActorSystemRemoveLocalActorRef action) {
    if (action is ActorSystemRemoveUserLocalActorRef) {
      _userActorRegister.removeByPath(action.path);
    } else if (action is ActorSystemRemoveSystemLocalActorRef) {
      _systemActorRegister.removeByPath(action.path);
    }
  }

  void _handleActorSystemGetLocalActorRefAction(
      ActorSystemGetLocalActorRef action) {
    if (action is ActorSystemGetUserLocalActorRef) {
      var ref = _userActorRegister.getRefByPath(action.actorPath);

      action.feedbackPort.send(ActorSystemGetLocalActorRefResult(ref));
    } else if (action is ActorSystemGetSystemLocalActorRef) {
      var ref = _systemActorRegister.getRefByPath(action.actorPath);

      action.feedbackPort.send(ActorSystemGetLocalActorRefResult(ref));
    }
  }

  void _handleActorSystemIsExistLocalActorRef(
      ActorSystemIsExistLocalActorRef action) {
    if (action is ActorSystemIsExistUserLocalActorRef) {
      var isExist = _userActorRegister.isExistsByPath(action.actorPath);

      action.feedbackPort.send(ActorSystemIsExistLocalActorRefResult(isExist));
    } else if (action is ActorSystemIsExistSystemLocalActorRef) {
      var isExist = _systemActorRegister.isExistsByPath(action.actorPath);

      action.feedbackPort.send(ActorSystemIsExistLocalActorRefResult(isExist));
    }
  }

  void _handleActorSystemAddTopicMessage(ActorSystemAddTopicMessage action) {
    _topicMessageController.sink.add(action.message);
  }

  void _handleActorSystemSetRemoteSources(ActorSystemSetRemoteSources action) {
    _remoteSources.clear();
    _remoteSources.addAll(action.remoteSources);
  }

  void _handleActorSystemCreateRemoteActorRef(
      ActorSystemCreateRemoteActorRef action) {
    RemoteSource? remoteSource;

    for (var source in _remoteSources) {
      if (source.connectionName == action.connectionName) {
        remoteSource = source;
        break;
      }
    }

    if (remoteSource != null) {
      var ref = remoteSource.createRemoteRef(action.path);

      action.feedbackPort.send(ActorSystemCreateRemoteActorRefSuccess(ref));
    } else {
      action.feedbackPort
          .send(ActorSystemCreateRemoteActorRefConnectionNotExist());
    }
  }

  void _handleActorSystemRouteActorRemoteMessage(
      ActorSystemRouteActorRemoteMessage action) {
    var message = action.message;

    for (var ref in _userActorRegister.refs) {
      if (ref.path == message.path) {
        ref.send(message.data);
        break;
      }
    }
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

  ///
  Future<void> pauseTopLevelActor(String path) async {}

  ///
  Future<void> resumeTopLevelActor(String path) async {}

  ///
  Future<void> killTopLevelActor(String path) async {}

  ///
  Future<void> deleteTopLevelActor(String path) async {}

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

      _userGuardianRef.sendMessage(SystemRoutingMessage(
          action, _userGuardianPath,
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

  /// Sends message to actor which in located on [path].
  ///
  /// If [delay] is not null, message sends after delay equals [delay].
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

  /// Sends message to actor which in located on [path] and return subscribe to message.
  ///
  /// If [delay] is not null, message sends after delay equals [delay].
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
  /// The relative path is set from [UserGuardian].
  ///
  /// For example, you can point out this path "system/root/user/my_actor" like "../my_actor".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
  LocalActorRef? getLocalActorRef(String path) {
    var actorPath = _parcePath(path);

    return _userActorRegister.getRefByPath(actorPath);
  }

  /// Checks if the register exist a reference to an actor with path - [path].
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
  bool isExistLocalActorRef(String path) {
    var actorPath = _parcePath(path);

    return _userActorRegister.isExistsByPath(actorPath);
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
