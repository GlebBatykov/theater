part of theater.dispatch;

/// It is one of the possible results of a response to a message sent to another actor without using a link to it.
///
/// Means that the actor with this address actually exists in the system of actors.
/// He received and processed the message sent to him, but did not send any response to it.
class DeliveredSuccessfullyResult extends MessageResponse {}
