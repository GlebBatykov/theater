part of theater.actor;

mixin UserActorContextMixin<P extends ActorProperties> on ActorContext<P> {
  /// Creates remote actor ref using connection to remote system with [connectionName].
  ///
  /// The [path] is specified only absolute, with the name of the system of actors, the root actor, the user guardian.
  ///
  /// Example: 'test_system/root/user/test_actor'.
  ///
  /// The created ref points to actor with absolute path [path].
  ///
  /// If actor system has no connection to remote system with [connectionName] an exception will be thrown.
  Future<RemoteActorRef> createRemoteActorRef(
      String connectionName, String path) async {
    if (!ActorPath.isRelativePath(path)) {
      var receivePort = ReceivePort();

      var actorPath = ActorPath.parceAbsolute(path);

      var action = ActorSystemCreateRemoteActorRef(
          receivePort.sendPort, connectionName, actorPath);

      _actorProperties.actorSystemMessagePort.send(action);

      var result =
          (await receivePort.first) as ActorSystemCreateRemoteActorRefResult;

      receivePort.close();

      if (result is ActorSystemCreateRemoteActorRefSuccess) {
        return result.ref;
      } else {
        throw RemoteActorRefException(
            message:
                'actor system has no connection with name: $connectionName.');
      }
    } else {
      throw RemoteActorRefException(
          message:
              'the path must be indicated absolutely and path must not be empty.');
    }
  }
}
