part of theater.actor;

class ActorNotifier {
  final SendPort _actorSystemSendPort;

  final Map<ActorSystemNotificationType, TypedNotifySubscription>
      _typedNotifySubscriptions = {};

  ReceivePort? _receivePort;

  StreamController<ActorSystemNotify>? _notifyStream;

  ActorNotifier(SendPort actorSystemSendPort)
      : _actorSystemSendPort = actorSystemSendPort;

  Subscription subscribe(
      ActorSystemNotificationType type, void Function(dynamic) handler) {
    _initialize();

    var entry = _getTypedNotifySubscription(type);

    var data = _createSubscriberData(entry, handler);

    return data.subscription;
  }

  void _initialize() {
    if (_receivePort == null) {
      _receivePort = ReceivePort();
      _notifyStream = StreamController.broadcast();

      _receivePort!.listen((message) {
        if (message is ActorSystemNotify) {
          _notifyStream!.sink.add(message);
        }
      });
    }
  }

  MapEntry<ActorSystemNotificationType, TypedNotifySubscription>
      _getTypedNotifySubscription(ActorSystemNotificationType type) {
    late MapEntry<ActorSystemNotificationType, TypedNotifySubscription> entry;

    if (!_typedNotifySubscriptions.containsKey(type)) {
      var typedNotifyController = StreamController.broadcast();

      var subscription = _notifyStream!.stream.listen((event) {
        print(event);

        if (event.type == type) {
          typedNotifyController.sink.add(event.message);
        }
      });

      var notifierSubscription =
          TypedNotifySubscription(typedNotifyController, subscription, []);

      _typedNotifySubscriptions[type] = notifierSubscription;
    }

    entry = _typedNotifySubscriptions.entries
        .firstWhere((element) => element.key == type);

    if (entry.value.subscribers.isEmpty) {
      _subscribeToNotification(type);
    }

    return entry;
  }

  void _subscribeToNotification(ActorSystemNotificationType type) {
    _actorSystemSendPort
        .send(ActorSystemSubscribeNotification(type, _receivePort!.sendPort));
  }

  SubscriberData _createSubscriberData(
      MapEntry<ActorSystemNotificationType, TypedNotifySubscription> entry,
      void Function(dynamic) handler) {
    late Subscription subscription;

    switch (entry.key) {
      case ActorSystemNotificationType.addIncomingConnection:
        var streamSubscription = entry.value.typedNotifyController.stream
            .map((event) => event as IncomingConnection)
            .listen(handler);

        subscription = Subscription<IncomingConnection>.fromStreamSubscription(
            streamSubscription);

        break;
      case ActorSystemNotificationType.removeIncomingConnection:
        var streamSubscription = entry.value.typedNotifyController.stream
            .map((event) => event as IncomingConnection)
            .listen(handler);

        subscription = Subscription<IncomingConnection>.fromStreamSubscription(
            streamSubscription);

        break;
    }

    var cancelSubscription = subscription.onCancel.listen((event) {
      _handleCloseSubscription(entry, subscription);
    });

    var data = SubscriberData(subscription, cancelSubscription);

    entry.value.subscribers.add(data);

    return data;
  }

  void _handleCloseSubscription(
      MapEntry<ActorSystemNotificationType, TypedNotifySubscription> entry,
      Subscription subscription) {
    entry.value.subscribers
        .removeWhere((element) => element.subscription == subscription);

    if (entry.value.subscribers.isEmpty) {
      _unsubscribeToNotification(entry.key);
    }
  }

  void _unsubscribeToNotification(ActorSystemNotificationType type) {
    _actorSystemSendPort
        .send(ActorSystemUnsubscribeNotification(type, _receivePort!.sendPort));
  }

  Future<void> dispose() async {
    await _notifyStream?.close();
    _receivePort?.close();

    for (var notifierSubscription in _typedNotifySubscriptions.entries) {
      for (var subscriber in notifierSubscription.value.subscribers) {
        await subscriber.cancelSubscription.cancel();
        await subscriber.subscription.cancel();
      }

      _unsubscribeToNotification(notifierSubscription.key);

      await notifierSubscription.value.notifySubscription.cancel();
      await notifierSubscription.value.typedNotifyController.close();
    }

    _receivePort = null;
    _notifyStream = null;
  }
}
