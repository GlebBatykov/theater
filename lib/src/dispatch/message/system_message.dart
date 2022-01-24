part of theater.dispatch;

abstract class SystemMessage extends Message {
  SystemMessage(dynamic data, SendPort? feedbackPort)
      : super(data, feedbackPort);
}
