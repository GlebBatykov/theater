part of theater.remote;

class GetActorsPathsMessage extends SystemRemoteMessage {
  final SendPort feedbackPort;

  GetActorsPathsMessage(this.feedbackPort);
}
