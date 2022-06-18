part of theater.actor;

abstract class RouterActorContext<P extends RouterActorProperties>
    extends NodeActorContext<P> with UserActorContextMixin<P> {
  int _nextRoundRobinWorker = 0;

  int? _lastRandomWorker;

  RouterActorContext(IsolateContext isolateContext, P actorProperties)
      : super(isolateContext, actorProperties);

  void _sendRoundRobin(MailboxMessage message) {
    _children[_nextRoundRobinWorker].ref.send(message);

    if (_nextRoundRobinWorker + 1 < _children.length) {
      _nextRoundRobinWorker += 1;
    } else {
      _nextRoundRobinWorker = 0;
    }
  }

  void _sendBroadcast(MailboxMessage message) {
    for (var child in _children) {
      child.ref.send(message);
    }
  }

  void _sendRandom(MailboxMessage message) {
    late int newRandomWorker;

    do {
      newRandomWorker = Random().nextInt(_children.length);
    } while (newRandomWorker == _lastRandomWorker);

    _children[newRandomWorker].ref.send(message);

    _lastRandomWorker = newRandomWorker;
  }
}
