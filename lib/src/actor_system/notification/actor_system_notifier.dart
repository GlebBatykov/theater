part of theater.actor_system;

class ActorSystemNotifier {
  final Map<ActorSystemNotificationType, List<SendPort>> _typedSubscribers = {};

  ActorSystemNotifier() {
    for (var type in ActorSystemNotificationType.values) {
      _typedSubscribers[type] = [];
    }
  }

  void handle(ActorSystemNotificationAction action) {
    if (action is ActroSystemSubscriptionAction) {
      _handleActroSystemSubscriptionAction(action);
    } else if (action is ActorSystemNotify) {
      _notify(action);
    }
  }

  void _handleActroSystemSubscriptionAction(
      ActroSystemSubscriptionAction action) {
    if (action is ActorSystemSubscribeNotification) {
      _subscribe(action);
    } else if (action is ActorSystemUnsubscribeNotification) {
      _unsubscribe(action);
    }
  }

  void _subscribe(ActorSystemSubscribeNotification action) {
    var subscribers = _typedSubscribers[action.type]!;

    if (!subscribers.contains(action.sendPort)) {
      subscribers.add(action.sendPort);
    }
  }

  void _unsubscribe(ActorSystemUnsubscribeNotification action) {
    _typedSubscribers[action.type]!.remove(action.sendPort);
  }

  void _notify(ActorSystemNotify action) {
    for (var sendPort in _typedSubscribers[action.type]!) {
      sendPort.send(action);
    }
  }
}
