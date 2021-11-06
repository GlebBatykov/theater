part of theater.actor;

abstract class SupervisorActorCellProperties extends ActorCellProperties {
  SupervisorActorCellProperties(Map<String, dynamic> data,
      void Function()? onKill, void Function(ActorError)? onError)
      : super(data, onKill, onError);
}
