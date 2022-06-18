part of theater.actor;

class ActorCellProperties {
  final SendPort actorSystemSendPort;

  final Map<String, dynamic> data;

  final LoggingProperties loggingProperties;

  final void Function()? onKill;

  final void Function(ActorError)? onError;

  ActorCellProperties(this.data, this.actorSystemSendPort,
      this.loggingProperties, this.onKill, this.onError);
}
