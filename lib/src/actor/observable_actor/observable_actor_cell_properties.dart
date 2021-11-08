part of theater.actor;

abstract class ObservableActorCellProperties extends ActorCellProperties {
  ObservableActorCellProperties(
      Map<String, dynamic> data,
      SendPort actorSystemMessagePort,
      void Function()? onKill,
      void Function(ActorError)? onError)
      : super(data, actorSystemMessagePort, onKill, onError);
}
