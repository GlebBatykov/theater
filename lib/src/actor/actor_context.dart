part of theater.actor;

/// This class is a base class for all actor context classes.
abstract class ActorContext<P extends ActorProperties>
    implements ActorMessageSender {
  /// Instance of [StreamController] who gets everything all [MailboxMessage] received.
  final StreamController<MailboxMessage> _messageController =
      StreamController.broadcast();

  /// Instance of [IsolateContext]. Contains ports for communication with isolate supervisor.
  final IsolateContext _isolateContext;

  /// Instance of [ActorProperties]. Contains actor settings for current actor.
  final P _actorProperties;

  /// Instanse of [Scheduler] of this actor context.
  final Scheduler _scheduler = Scheduler();

  /// Path to current actor in actor system.
  ActorPath get path => _actorProperties.path;

  /// Instanse of [Scheduler] of this actor context.
  Scheduler get scheduler => _scheduler;

  /// The data which was transferred to actor during initialization.
  Map<String, dynamic> get data => Map.unmodifiable(_actorProperties.data);

  ActorContext(IsolateContext isolateContext, P actorProperties)
      : _isolateContext = isolateContext,
        _actorProperties = actorProperties;

  /// Initializes current actor context.
  Future<void> _initialize() async {}

  /// Kills current actor and him children.
  void kill() {
    _isolateContext.supervisorMessagePort.send(ActorWantsToDie());
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
  /// The relative path is set from current actor.
  ///
  /// For example current actor has the name "my_actor", you can point out this path "system/root/user/my_actor/my_child" like "../my_child".
  ///
  /// Absolute path given by the full path to the actor from the name of the system of actors.
  @override
  MessageSubscription send(String path, dynamic data, {Duration? duration}) {
    var recipientPath = _parcePath(path);

    var receivePort = ReceivePort();

    var message =
        ActorRoutingMessage(data, receivePort.sendPort, recipientPath);

    if (duration != null) {
      Future.delayed(duration, () {
        _handleRoutingMessage(message);
      });
    } else {
      _handleRoutingMessage(message);
    }

    return MessageSubscription(receivePort);
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
}
