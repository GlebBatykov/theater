part of theater.actor;

class ActorCellProperties {
  final SendPort actorSystemMessagePort;

  final Map<String, dynamic> data;

  final void Function()? onKill;

  final void Function(ActorError)? onError;

  ActorCellProperties(
      this.data, this.actorSystemMessagePort, this.onKill, this.onError);
}
