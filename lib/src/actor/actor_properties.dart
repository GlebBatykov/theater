part of theater.actor;

abstract class ActorProperties {
  final ActorPath path;

  final HandlingType handlingType;

  final MailboxType mailboxType;

  final LocalActorRef actorRef;

  final SendPort actorSystemSendPort;

  final ActorLoggingProperties loggingProperties;

  final Map<String, dynamic> data;

  ActorProperties(
      {required LocalActorRef actorRef,
      required this.handlingType,
      required this.mailboxType,
      required this.actorSystemSendPort,
      required this.loggingProperties,
      required this.data})
      : path = actorRef.path,
        actorRef = actorRef;
}
