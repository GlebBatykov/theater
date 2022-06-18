part of theater.remote;

class ActorRemoteTransportMessage extends RemoteTransportMessage {
  final ActorPath path;

  final String tag;

  final String data;

  ActorRemoteTransportMessage(this.path, this.tag, this.data);
}
