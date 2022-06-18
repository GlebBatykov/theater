part of theater.actor;

class NodeActorCellProperties extends SupervisorActorCellProperties {
  final LocalActorRef parentRef;

  NodeActorCellProperties(
      {required this.parentRef,
      Map<String, dynamic>? data,
      required SendPort actorSystemSendPort,
      required LoggingProperties loggingProperties,
      void Function()? onKill,
      void Function(ActorError)? onError})
      : super(data ?? {}, actorSystemSendPort, loggingProperties, onKill,
            onError);
}
