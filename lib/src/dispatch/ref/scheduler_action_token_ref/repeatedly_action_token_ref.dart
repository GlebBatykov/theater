part of theater.dispatch;

///
class RepeatedlyActionTokenRef extends SchedulerActionTokenRef {
  RepeatedlyActionTokenRef(SendPort tokenSendPort) : super(tokenSendPort);

  ///
  Future<RepeatedlyActionStatus> getStatus() async {
    var receivePort = ReceivePort();

    _tokenSendPort.send(RepeatedlyActionTokenGetStatus(receivePort.sendPort));

    var response = (await receivePort.first) as RepeatedlyActionTokenStatus;

    receivePort.close();

    return response.status;
  }

  ///
  Future<bool> isRunning() async {
    var status = await getStatus();

    return status == RepeatedlyActionStatus.running;
  }

  ///
  Future<bool> isStoped() async {
    var status = await getStatus();

    return status == RepeatedlyActionStatus.stopped;
  }

  ///
  void stop() {
    _tokenSendPort.send(RepeatedlyActionTokenStop());
  }

  ///
  void resume() {
    _tokenSendPort.send(RepeatedlyActionTokenResume());
  }
}
