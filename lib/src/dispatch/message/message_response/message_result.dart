part of theater.dispatch;

/// It is one of the possible results of a response to a message sent to another actor.
///
/// Means that the actor has processed the sent message and sent a response to it.
class MessageResult extends MessageResponse {
  final dynamic data;

  MessageResult({required this.data});
}
