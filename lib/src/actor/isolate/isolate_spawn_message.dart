part of theater.actor;

class IsolateSpawnMessage {
  final SendPort supervisorMessagePort;

  final SendPort supervisorErrorPort;

  final Actor actor;

  final ActorProperties actorProperties;

  final ActorIsolateHandlerFactory isolateHandlerFactory;

  final ActorContextFactory contextFactory;

  final Map<String, dynamic> data;

  IsolateSpawnMessage(
      this.supervisorMessagePort,
      this.supervisorErrorPort,
      this.actor,
      this.actorProperties,
      this.isolateHandlerFactory,
      this.contextFactory,
      this.data);
}
