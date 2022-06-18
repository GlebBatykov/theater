part of theater.remote;

class GetActorsPathsResultTransportMessage
    extends SystemRemoteTransportMessage {
  final int id;

  final List<ActorPath> paths;

  GetActorsPathsResultTransportMessage(this.id, this.paths);
}
