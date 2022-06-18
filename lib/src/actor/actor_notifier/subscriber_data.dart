part of theater.actor;

class SubscriberData {
  final Subscription subscription;

  final StreamSubscription cancelSubscription;

  SubscriberData(this.subscription, this.cancelSubscription);
}
