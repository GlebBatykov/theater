part of theater.actor;

class ActorSystem implements ActorRefFactory<NodeActor>, ActorMessageSender {
  /// Name of actor system. Used in [ActorPath] of everyone actors.
  final String name;

  /// [ActorPath] instance of [RootActor] actor.
  late final ActorPath _rootPath;

  /// [ActorPath] instance of [UserGuardian] actor.
  late final ActorPath _userGuardianPath;

  /// [ActorPath] instance of [SystemGuardian] actor.
  late final ActorPath _systemGuardianPath;

  /// [RootActorCell] instance of root actor.
  late final RootActorCell _root;

  /// Contains all top-level actor names.
  final List<String> _topLevelActorNames = [];

  /// Used in creation top-level actors, needs for receive response from [UserGuardian].
  ///
  /// If [ActorSystem] call [dispose] method and in this time some top-level actor is in the making - closes all port.
  final List<ReceivePort> _createChildReceivePorts = [];

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
  ActorSystem(this.name) {
    _rootPath = ActorPath(Address(name), 'root', 0);

    _userGuardianPath = _rootPath.createChild('user');

    _systemGuardianPath = _rootPath.createChild('system');

    _root = RootActorCell(_rootPath, DefaultRootActor());

    // If root actor escalate error. Prints stackTrace and dispose actor system.
    _root.errors.listen((error) {
      dispose();

      throw ActorSystemException(
          message: 'in actor system unhandled exception occurred.\n\n' +
              error.toString());
    });
  }

  /// Uses by the primary initialization [ActorSystem]. Creates and starts root actor and guardians, system actors.
  ///
  /// Before work with actor system you must initialize her.
  Future<void> initialize() async {
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

      var action = ActorCreateChild(name, actor, data, onKill);

      _root.ref.sendMessage(SystemRoutingMessage(
          action, receivePort.sendPort, _userGuardianPath));

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
  MessageSubscription send(String path, dynamic data, {Duration? duration}) {
    var recipientPath = _parcePath(path);

    var receivePort = ReceivePort();

    if (duration != null) {
      Future.delayed(duration, () {
        _root.ref.sendMessage(
            ActorRoutingMessage(data, receivePort.sendPort, recipientPath));
      });
    } else {
      _root.ref.sendMessage(
          ActorRoutingMessage(data, receivePort.sendPort, recipientPath));
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

  /// Kills all actors in actor system and frees all resources, close all streams that were used by the actor system.
  Future<void> dispose() async {
    await _root.dispose();

    for (var port in _createChildReceivePorts) {
      port.close();
    }
  }
}
