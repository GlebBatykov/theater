part of theater.actor;

abstract class SupervisorActorCellProperties extends ActorCellProperties {
  SupervisorActorCellProperties(
      Map<String, dynamic> data,
      SendPort actorSystemMessagePort,
      void Function()? onKill,
      void Function(ActorError)? onError)
      : super(data, actorSystemMessagePort, onKill, onError);
}
