part of theater.actor_system;

abstract class ActorSystemNotificationAction extends ActorSystemAction {
  final ActorSystemNotificationType type;

  ActorSystemNotificationAction(this.type);
}

abstract class ActroSystemSubscriptionAction
    extends ActorSystemNotificationAction {
  final SendPort sendPort;

  ActroSystemSubscriptionAction(super.type, this.sendPort);
}

class ActorSystemSubscribeNotification extends ActroSystemSubscriptionAction {
  ActorSystemSubscribeNotification(super.type, super.sendPort);
}

class ActorSystemUnsubscribeNotification extends ActroSystemSubscriptionAction {
  ActorSystemUnsubscribeNotification(super.type, super.sendPort);
}

class ActorSystemNotify extends ActorSystemNotificationAction {
  final dynamic message;

  ActorSystemNotify(super.type, this.message);
}
