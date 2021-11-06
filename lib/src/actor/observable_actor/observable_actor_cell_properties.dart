part of theater.actor;

abstract class ObservableActorCellProperties extends ActorCellProperties {
  ObservableActorCellProperties(Map<String, dynamic> data,
      void Function()? onKill, void Function(ActorError)? onError)
      : super(data, onKill, onError);
}
