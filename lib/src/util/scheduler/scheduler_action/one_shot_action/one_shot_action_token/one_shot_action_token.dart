part of theater.util;

/// Used in the scheduler to call one shot actions.
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

  /// Calls all action which bonded with this token.
  void call() {
    _eventController.sink.add(OneShotActionEventCall());
  }

  /// Add listener to call event.
  void addOnCallListener(void Function() listener) {
    _eventController.stream
        .where((event) => event is OneShotActionEventCall)
        .listen((event) => listener());
  }
}
