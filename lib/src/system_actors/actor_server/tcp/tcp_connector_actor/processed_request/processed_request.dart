part of theater.system_actors;

class ProcessedRequest {
  final int id;

  final ProcessedRequestType type;

  final SendPort feedbackPort;

  ProcessedRequest(this.id, this.type, this.feedbackPort);

  @override
  bool operator ==(other) {
    if (other is ProcessedRequest) {
      return id == other.id;
    } else {
      return false;
    }
  }
}
