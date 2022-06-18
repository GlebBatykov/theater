part of theater.actor;

abstract class ObservableActorProperties extends ActorProperties {
  ObservableActorProperties(
      {required super.actorRef,
      required super.handlingType,
      required super.mailboxType,
      required super.actorSystemSendPort,
      required super.loggingProperties,
      required super.data});
}
