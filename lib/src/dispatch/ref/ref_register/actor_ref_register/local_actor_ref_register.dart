part of theater.dispatch;

class LocalActorRefRegister extends RefRegister<LocalActorRef> {
  void registerRef(LocalActorRef ref) {
    _refs.add(ref);
  }

  bool isExistsByPath(ActorPath path) {
    return _refs.where((element) => element.path == path).isNotEmpty;
  }

  LocalActorRef? getRefByPath(ActorPath path) {
    var refs = _refs.where((element) => element.path == path);

    return refs.isNotEmpty ? refs.first : null;
  }
}
