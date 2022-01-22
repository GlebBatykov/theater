part of theater.dispatch;

/// Used by sending messages to actor mailbox.
abstract class ActorRef extends Ref {
  /// Path to the actor whose mailbox the ref point to.
  final ActorPath path;

  ActorRef(this.path, SendPort sendPort) : super(sendPort);
}
