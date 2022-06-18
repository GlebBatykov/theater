part of theater.actor;

abstract class ObservableActorCellProperties extends ActorCellProperties {
  ObservableActorCellProperties(
      Map<String, dynamic> data,
      SendPort actorSystemSendPort,
      LoggingProperties loggingProperties,
      void Function()? onKill,
      void Function(ActorError)? onError)
      : super(data, actorSystemSendPort, loggingProperties, onKill, onError);
}
