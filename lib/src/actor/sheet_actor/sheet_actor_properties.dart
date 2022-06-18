part of theater.actor;

abstract class SheetActorProperties extends ObservableActorProperties {
  final LocalActorRef parentRef;

  SheetActorProperties(
      {required this.parentRef,
      required super.handlingType,
      required super.actorRef,
      required super.mailboxType,
      required super.actorSystemSendPort,
      required super.loggingProperties,
      required super.data});
}
