part of theater.dispatch;

/// It is one of the possible results of a response to a message sent to another actor without using a link to it.
///
/// Means that the actor with this address does not exist in the system of actors.
class RecipientNotFoundResult extends MessageResponse {}
