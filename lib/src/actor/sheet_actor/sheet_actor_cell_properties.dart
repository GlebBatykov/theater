part of theater.actor;

abstract class SheetActorCellProperties extends ObservableActorCellProperties {
  final LocalActorRef parentRef;

  SheetActorCellProperties(
      this.parentRef,
      Map<String, dynamic> data,
      SendPort actorSystemMessagePort,
      void Function()? onKill,
      void Function(ActorError)? onError)
      : super(data, actorSystemMessagePort, onKill, onError);
}
