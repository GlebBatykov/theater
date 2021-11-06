part of theater.actor;

class ActorCellProperties {
  final Map<String, dynamic> data;

  final void Function()? onKill;

  final void Function(ActorError)? onError;

  ActorCellProperties(this.data, this.onKill, this.onError);
}
