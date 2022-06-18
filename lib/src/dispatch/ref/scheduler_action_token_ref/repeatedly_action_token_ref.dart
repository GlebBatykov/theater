part of theater.dispatch;

///
class RepeatedlyActionTokenRef extends SchedulerActionTokenRef {
  RepeatedlyActionTokenRef(SendPort sendPort) : super(sendPort);

  ///
  Future<RepeatedlyActionStatus> getStatus() async {
    var receivePort = ReceivePort();

    _sendPort.send(RepeatedlyActionTokenGetStatus(receivePort.sendPort));

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
    _sendPort.send(RepeatedlyActionTokenStop());
  }

  ///
  void resume() {
    _sendPort.send(RepeatedlyActionTokenResume());
  }

  ///
  void changeInterval(Duration interval) {
    _sendPort.send(RepeatedlyActionTokenChangeInterval(interval));
  }
}
