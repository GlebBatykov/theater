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
  final LoggingProperties _loggerProperties;

  /// List of [RemoteSource] which are used to send messages to other actor systems using Theater Remote.
  final List<ConnectorSource> _remoteSources = [];

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

  late final ActorPath _actorServerPath;

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

  ///
  final ActorSystemNotifier _notifier = ActorSystemNotifier();

  bool _isDisposed = false;

  /// Used in creation top-level actors, needs for receive response from [UserGuardian].
  ///
  /// If [ActorSystem] call [dispose] method and in this time some top-level actor is in the making - closes all port.
  final List<ReceivePort> _createChildReceivePorts = [];

  /// Shows the status of dispose.
  bool get isDisposed => _isDisposed;

  ActorSystem(this.name,
      {RemoteTransportConfiguration? remoteConfiguration,
      LoggingProperties? loggingProperties})
      : _remoteConfiguration = remoteConfiguration ??
            RemoteTransportConfiguration(isRemoteTransportEnabled: false),
        _loggerProperties = loggingProperties ??
            LoggingProperties(loggerFactory: TheaterLoggerFactory()) {
    _rootPath = ActorPath(name, SystemActorNames.root, 0);

    _userGuardianPath = _rootPath.createChild(SystemActorNames.userGuardian);

    _systemGuardianPath =
        _rootPath.createChild(SystemActorNames.systemGuardian);

    _actorServerPath =
        _systemGuardianPath.createChild(SystemActorNames.actorSystemServer);
  }

  /// Create and initialize actor system.
  static Future<ActorSystem> spawn(String name,
      {RemoteTransportConfiguration? remoteConfiguration,
      LoggingProperties? loggingProperties}) async {
    var system = ActorSystem(name,
        remoteConfiguration: remoteConfiguration,
        loggingProperties: loggingProperties);

    await system.initialize();

    return system;
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
        _messagePort.sendPort,
        _loggerProperties);

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
    } else if (action is ActorSystemGetUserActorsPaths) {
      _handleActorSystemGetUserActorsPaths(action);
    } else if (action is ActorSystemGetRemoteUserActorsPaths) {
      _handleActorSystemGetRemoteUserActorsPaths(action);
    } else if (action is ActorSystemIsRemoteConnectionExist) {
      _handleActorSystemIsRemoteConnectionExist(action);
    } else if (action is ActorSystemGetRemoteConnections) {
      _handleActorSystemGetRemoteConnections(action);
    } else if (action is ActorSystemGetRemoteConnection) {
      _handleActorSystemGetRemoteConnection(action);
    } else if (action is ActorSystemNotificationAction) {
      _notifier.handle(action);
    } else if (action is ActorSystemCreateConnector) {
      _handleActorSystemCreateConnector(action);
    } else if (action is ActorSystemCreateServer) {
      _handleActorSystemCreateServer(action);
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
    var remoteSource = _searchRemoteSource(action.connectionName);

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

  void _handleActorSystemGetUserActorsPaths(
      ActorSystemGetUserActorsPaths action) {
    var paths = _userActorRegister.refs.map((e) => e.path).toList();

    action.feedbackPort.send(ActorSystemGetUserActorsPathsResult(paths));
  }

  void _handleActorSystemGetRemoteUserActorsPaths(
      ActorSystemGetRemoteUserActorsPaths action) async {
    var remoteSource = _searchRemoteSource(action.connectionName);

    if (remoteSource != null) {
      var receivePort = ReceivePort();

      remoteSource.birdgeSendPort
          .send(GetActorsPathsMessage(receivePort.sendPort));

      var result = (await receivePort.first) as GetActorsPathsResultMessage;

      receivePort.close();

      action.feedbackPort
          .send(ActorSystemGetRemoteUserActorsPathsSuccess(result.paths));
    } else {
      action.feedbackPort
          .send(ActorSystemGetRemoteUserActorsPathsConnectionNotExist());
    }
  }

  void _handleActorSystemIsRemoteConnectionExist(
      ActorSystemIsRemoteConnectionExist action) {
    var remoteSource = _searchRemoteSource(action.connectionName);

    late ActorSystemIsRemoteConnectionExistResult result;

    if (remoteSource != null) {
      result = ActorSystemRemoteConnectionExist();
    } else {
      result = ActorSystemRemoteConnectionNotExist();
    }

    action.feedbackPort.send(result);
  }

  void _handleActorSystemGetRemoteConnections(
      ActorSystemGetRemoteConnections action) {
    var connections = _remoteSources.map((e) => e.connection).toList();

    action.feedbackPort
        .send(ActorSystemGetRemoteConnectionsResult(connections));
  }

  void _handleActorSystemGetRemoteConnection(
      ActorSystemGetRemoteConnection action) {
    var remoteSource = _searchRemoteSource(action.connectionName);

    late ActorSystemGetRemoteConnectionResult result;

    if (remoteSource != null) {
      result = ActorSystemGetRemoteConnectionSuccess(remoteSource.connection);
    } else {
      result = ActorSystemGetRemoteConnectionNotExist();
    }

    action.feedbackPort.send(result);
  }

  void _handleActorSystemCreateConnector(
      ActorSystemCreateConnector action) async {
    var receivePort = ReceivePort();

    _systemActorRegister.getRefByPath(_actorServerPath)!.send(
        SystemMailboxMessage(ActorSystemServerCreateConnector(
            action.configuration, receivePort.sendPort)));

    var result =
        (await receivePort.first) as ActorSystemServerCreateConnectorResult;

    receivePort.close();

    if (result is ActorSystemServerCreateConnectorSuccess) {
      var source = result.source;

      _remoteSources.add(source);

      action.feedbackPort
          .send(ActorSystemCreateConnectorSuccess(source.connection));
    } else if (result is ActorSystemServerCreateConnectorNameExist) {
      action.feedbackPort.send(ActorSystemCreateConnectorNameExist());
    }
  }

  void _handleActorSystemCreateServer(ActorSystemCreateServer action) async {
    var receivePort = ReceivePort();

    _systemActorRegister.getRefByPath(_actorServerPath)!.send(
        SystemMailboxMessage(ActorSystemServerCreateServer(
            action.configuration, receivePort.sendPort)));

    var result =
        (await receivePort.first) as ActorSystemServerCreateServerResult;

    receivePort.close();

    if (result is ActorSystemServerCreateServerSuccess) {
      action.feedbackPort.send(ActorSystemCreateServerSuccess());
    } else {
      action.feedbackPort.send(ActorSystemCreateServerNameExist());
    }
  }

  ConnectorSource? _searchRemoteSource(String connectionName) {
    ConnectorSource? remoteSource;

    for (var source in _remoteSources) {
      if (source.connectionName == connectionName) {
        remoteSource = source;
        break;
      }
    }

    return remoteSource;
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

  /// Starts top level actor in actor system with [path].
  Future<void> startTopLevelActor(String path) async {
    var actorPath = _parcePath(path);

    if (_isTopLevelActorExist(actorPath)) {
      var receivePort = ReceivePort();

      _userGuardianRef.send(SystemMailboxMessage(
          UserGuardianStartTopLevelActor(actorPath),
          feedbackPort: receivePort.sendPort));

      await for (var message in receivePort) {
        if (message is MessageResult) {
          break;
        }
      }
    } else {
      throw ActorSystemException(
          message:
              'actor system does not contain top level actor with path: $path.');
    }
  }

  /// Pauses top level actor in actor system with [path].
  Future<void> pauseTopLevelActor(String path) async {
    var actorPath = _parcePath(path);

    if (_isTopLevelActorExist(actorPath)) {
      var receivePort = ReceivePort();

      _userGuardianRef.send(SystemMailboxMessage(
          UserGuardianPauseTopLevelActor(actorPath),
          feedbackPort: receivePort.sendPort));

      await for (var message in receivePort) {
        if (message is MessageResult) {
          break;
        }
      }
    } else {
      throw ActorSystemException(
          message:
              'actor system does not contain top level actor with path: $path.');
    }
  }

  /// Resumes top level actor in actor system with [path].
  Future<void> resumeTopLevelActor(String path) async {
    var actorPath = _parcePath(path);

    if (_isTopLevelActorExist(actorPath)) {
      var receivePort = ReceivePort();

      _userGuardianRef.send(SystemMailboxMessage(
          UserGuardianResumeTopLevelActor(actorPath),
          feedbackPort: receivePort.sendPort));

      await for (var message in receivePort) {
        if (message is MessageResult) {
          break;
        }
      }
    } else {
      throw ActorSystemException(
          message:
              'actor system does not contain top level actor with path: $path.');
    }
  }

  /// Kills top level actor in actor system with [path].
  Future<void> killTopLevelActor(String path) async {
    var actorPath = _parcePath(path);

    if (_isTopLevelActorExist(actorPath)) {
      var receivePort = ReceivePort();

      _userGuardianRef.send(SystemMailboxMessage(
          UserGuardianKillTopLevelActor(actorPath),
          feedbackPort: receivePort.sendPort));

      await for (var message in receivePort) {
        if (message is MessageResult) {
          break;
        }
      }
    } else {
      throw ActorSystemException(
          message:
              'actor system does not contain top level actor with path: $path.');
    }
  }

  /// Deletes top level actor in actor system with [path].
  Future<void> deleteTopLevelActor(String path) async {
    var actorPath = _parcePath(path);

    if (_isTopLevelActorExist(actorPath)) {
      var receivePort = ReceivePort();

      _userGuardianRef.send(SystemMailboxMessage(
          UserGuardianDeleteTopLevelActor(actorPath),
          feedbackPort: receivePort.sendPort));

      await for (var message in receivePort) {
        if (message is MessageResult) {
          break;
        }
      }
    } else {
      throw ActorSystemException(
          message:
              'actor system does not contain top level actor with path: $path.');
    }
  }

  bool _isTopLevelActorExist(ActorPath path) {
    for (var name in _topLevelActorNames) {
      if (_userGuardianPath.createChild(name) == path) {
        return true;
      }
    }

    return false;
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

      _userGuardianRef.send(
          SystemMailboxMessage(action, feedbackPort: receivePort.sendPort));

      late LocalActorRef actorRef;

      await for (var message in receivePort) {
        if (message is MessageResult) {
          actorRef = message.data;
          break;
        }
      }

      _topLevelActorNames.add(name);
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
        _root.ref.send(ActorRoutingMessage(data, recipientPath));
      });
    } else {
      _root.ref.send(ActorRoutingMessage(data, recipientPath));
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
        _root.ref.send(ActorRoutingMessage(data, recipientPath,
            feedbackPort: receivePort.sendPort));
      });
    } else {
      _root.ref.send(ActorRoutingMessage(data, recipientPath,
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

  /// Creates remote actor ref using connection to remote system with [connectionName].
  ///
  /// The [path] is specified only absolute, with the name of the system of actors, the root actor, the user guardian.
  ///
  /// Example: 'test_system/root/user/test_actor'.
  ///
  /// The created ref points to actor with absolute path [path].
  ///
  /// If actor system has no connection to remote system with [connectionName] an exception will be thrown.
  RemoteActorRef createRemoteActorRef(String connectionName, String path) {
    if (_root.isInitialized) {
      ConnectorSource? remoteSource;

      for (var source in _remoteSources) {
        if (source.connectionName == connectionName) {
          remoteSource = source;
          break;
        }
      }

      if (remoteSource != null) {
        var actorPath = ActorPath.parceAbsolute(path);

        return remoteSource.createRemoteRef(actorPath);
      } else {
        throw ActorSystemException(
            message:
                'actor system has no connection with name: $connectionName.');
      }
    } else {
      throw ActorSystemException(message: 'actor system is not initialized.');
    }
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
