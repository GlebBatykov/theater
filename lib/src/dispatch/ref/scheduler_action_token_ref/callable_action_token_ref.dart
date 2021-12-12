part of theater.dispatch;

///
class OneShotActionTokenRef extends SchedulerActionTokenRef {
  OneShotActionTokenRef(SendPort tokenSendPort) : super(tokenSendPort);

  ///
  void call() {
    _tokenSendPort.send(OneShotActionTokenCall());
  }
}
