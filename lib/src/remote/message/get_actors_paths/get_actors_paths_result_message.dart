part of theater.remote;

class GetActorsPathsResultMessage extends SystemRemoteMessage {
  final List<ActorPath> paths;

  GetActorsPathsResultMessage(this.paths);
}
