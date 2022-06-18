part of theater.actor;

abstract class SheetActorCellProperties extends ObservableActorCellProperties {
  final LocalActorRef parentRef;

  SheetActorCellProperties(
      this.parentRef,
      Map<String, dynamic> data,
      SendPort actorSystemSendPort,
      LoggingProperties loggingProperties,
      void Function()? onKill,
      void Function(ActorError)? onError)
      : super(data, actorSystemSendPort, loggingProperties, onKill, onError);
}
