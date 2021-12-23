part of theater.util;

typedef OneShotActionCallback = void Function(OneShotActionContext);

class OneShotAction extends SchedulerAction {
  final OneShotActionCallback _action;

  final OneShotActionToken _actionToken;

  OneShotAction(
      {required OneShotActionCallback action,
      required OneShotActionToken actionToken})
      : _action = action,
        _actionToken = actionToken {
    _actionToken.addOnCallListener(() => call());
  }

  void call() {
    _action(OneShotActionContext(counter));
  }
}
