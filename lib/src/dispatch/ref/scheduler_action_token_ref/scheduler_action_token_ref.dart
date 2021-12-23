part of theater.dispatch;

///
abstract class SchedulerActionTokenRef extends Ref {
  final SendPort _tokenSendPort;

  SchedulerActionTokenRef(SendPort tokenSendPort)
      : _tokenSendPort = tokenSendPort;
}
