part of theater.dispatch;

/// Used to send message to actor wich licated in other actor system.
class RemoteActorRef extends ActorRef {
  /// Address where the remote actor system is located.
  final dynamic address;

  /// Port where the remote actor system is located.
  final int port;

  RemoteActorRef(ActorPath path, this.address, this.port, SendPort sendPort)
      : super(path, sendPort);

  /// Sends message with [tag].
  void send(String tag, dynamic message, {Duration? delay}) {
    _sendPort.send(ActorRemoteMessage(path, tag, message));
  }
}
