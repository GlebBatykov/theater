part of theater.util;

///
class OneShotActionToken
    extends SchedulerActionToken<OneShotActionEvent, OneShotActionTokenRef> {
  @override
  OneShotActionTokenRef get ref {
    if (_receivePort == null) {
      _receivePort = ReceivePort();

      _receivePort!.listen((message) {
        if (message is OneShotActionTokenEvent) {
          _handleCallableActionTokenEvent(message);
        }
      });
    }

    return OneShotActionTokenRef(_receivePort!.sendPort);
  }

  void _handleCallableActionTokenEvent(OneShotActionTokenEvent event) {
    if (event is OneShotActionTokenCall) {
      call();
    }
  }

  ///
  void call() {
    _eventController.sink.add(OneShotActionEventCall());
  }

  ///
  void addOnCallListener(void Function() listener) {
    _eventController.stream
        .where((event) => event is OneShotActionEventCall)
        .listen((event) => listener());
  }
}
