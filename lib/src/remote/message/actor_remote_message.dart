part of theater.remote;

class ActorRemoteMessage extends RemoteMessage {
  final ActorPath path;

  final String tag;

  final dynamic data;

  ActorRemoteMessage(this.path, this.tag, this.data);
}
