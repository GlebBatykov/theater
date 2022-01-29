part of theater.dispatch;

abstract class Message {
  final dynamic data;

  final SendPort? feedbackPort;

  bool get isHaveSubscription => feedbackPort != null;

  Message(this.data, this.feedbackPort);

  void successful() {
    feedbackPort?.send(DeliveredSuccessfullyResult());
  }

  void notFound() {
    feedbackPort?.send(RecipientNotFoundResult());
  }

  void sendResult(dynamic result) {
    feedbackPort?.send(MessageResult(data: result));
  }
}
