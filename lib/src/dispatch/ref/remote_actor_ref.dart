part of theater.dispatch;

///
class RemoteActorRef extends ActorRef {
  ///
  final dynamic address;

  ///
  final int port;

  RemoteActorRef(ActorPath path, this.address, this.port, SendPort sendPort)
      : super(path, sendPort);

  ///
  void send(String tag, dynamic message, {Duration? delay}) {
    _sendPort.send(ActorRemoteMessage(path, tag, message));
  }
}
