part of theater.actor;

class NodeActorCellProperties extends SupervisorActorCellProperties {
  final LocalActorRef parentRef;

  NodeActorCellProperties(
      {required this.parentRef,
      Map<String, dynamic>? data,
      required SendPort actorSystemMessagePort,
      void Function()? onKill,
      void Function(ActorError)? onError})
      : super(data ?? {}, actorSystemMessagePort, onKill, onError);
}
