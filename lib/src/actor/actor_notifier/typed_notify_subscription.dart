part of theater.actor;

class TypedNotifySubscription {
  final StreamController typedNotifyController;

  final StreamSubscription<ActorSystemNotify> notifySubscription;

  final List<SubscriberData> subscribers;

  TypedNotifySubscription(
      this.typedNotifyController, this.notifySubscription, this.subscribers);
}
