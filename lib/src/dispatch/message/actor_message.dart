part of theater.dispatch;

abstract class ActorMessage extends Message {
  ActorMessage(dynamic data, SendPort? feedbackPort)
      : super(data, feedbackPort);
}
