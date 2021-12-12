part of theater.dispatch;

class ActorSystemTopicMessage extends ActorMessage {
  final String topicName;

  ActorSystemTopicMessage(this.topicName, dynamic data,
      {SendPort? feedbackPort})
      : super(data, feedbackPort);
}
