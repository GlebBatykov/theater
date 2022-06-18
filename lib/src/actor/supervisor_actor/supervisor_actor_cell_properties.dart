part of theater.actor;

abstract class SupervisorActorCellProperties extends ActorCellProperties {
  SupervisorActorCellProperties(
      Map<String, dynamic> data,
      SendPort actorSystemSendPort,
      LoggingProperties loggingProperties,
      void Function()? onKill,
      void Function(ActorError)? onError)
      : super(data, actorSystemSendPort, loggingProperties, onKill, onError);
}
