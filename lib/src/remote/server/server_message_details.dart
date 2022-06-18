part of theater.remote;

class SystemMessageDetails {
  final SystemRemoteTransportMessage remoteMessage;

  final Connection sender;

  SystemMessageDetails(this.remoteMessage, this.sender);
}
