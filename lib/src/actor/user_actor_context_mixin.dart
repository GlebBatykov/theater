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

      _actorProperties.actorSystemSendPort.send(action);

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

  ///
  Future<List<ActorPath>> getRemoteActorsPaths(String connectionName) async {
    var receivePort = ReceivePort();

    _actorProperties.actorSystemSendPort.send(
        ActorSystemGetRemoteUserActorsPaths(
            receivePort.sendPort, connectionName));

    var result =
        (await receivePort.first) as ActorSystemGetRemoteUserActorsPathsResult;

    receivePort.close();

    if (result is ActorSystemGetRemoteUserActorsPathsSuccess) {
      return result.paths;
    } else {
      throw RemoteActorRefException(
          message:
              'actor system has no connection with name: $connectionName.');
    }
  }

  ///
  Future<bool> isRemoteConnectionExist(String connectionName) async {
    var receivePort = ReceivePort();

    _actorProperties.actorSystemSendPort.send(
        ActorSystemIsRemoteConnectionExist(
            receivePort.sendPort, connectionName));

    var result =
        (await receivePort.first) as ActorSystemIsRemoteConnectionExistResult;

    receivePort.close();

    return result is ActorSystemRemoteConnectionExist;
  }

  ///
  Future<OutgoingConnection> getOutgoingConnection(
      String connectionName) async {
    var receivePort = ReceivePort();

    _actorProperties.actorSystemSendPort.send(
        ActorSystemGetRemoteConnection(receivePort.sendPort, connectionName));

    var result =
        (await receivePort.first) as ActorSystemGetRemoteConnectionResult;

    receivePort.close();

    if (result is ActorSystemGetRemoteConnectionSuccess) {
      return result.connection;
    } else {
      throw RemoteActorRefException(
          message:
              'actor system has no connection with name: $connectionName.');
    }
  }

  ///
  Future<List<OutgoingConnection>> getOutgoingConnections() async {
    var receivePort = ReceivePort();

    _actorProperties.actorSystemSendPort
        .send(ActorSystemGetRemoteConnections(receivePort.sendPort));

    var result =
        (await receivePort.first) as ActorSystemGetRemoteConnectionsResult;

    receivePort.close();

    return result.connections;
  }

  ///
  Subscription<IncomingConnection> onAddIncomingConnection(
      void Function(IncomingConnection connection) handler) {
    var subscription = _notifier
        .subscribe(ActorSystemNotificationType.addIncomingConnection, (data) {
      handler(data as IncomingConnection);
    });

    return subscription as Subscription<IncomingConnection>;
  }

  ///
  Subscription<IncomingConnection> onRemoveIncomingConnection(
      void Function(IncomingConnection connection) handler) {
    var subscription = _notifier.subscribe(
        ActorSystemNotificationType.removeIncomingConnection, (data) {
      handler(data as IncomingConnection);
    });

    return subscription as Subscription<IncomingConnection>;
  }

  //
  Future<OutgoingConnection> createConnector(
      ConnectorConfiguration configuration) async {
    var receivePort = ReceivePort();

    _actorProperties.actorSystemSendPort
        .send(ActorSystemCreateConnector(configuration, receivePort.sendPort));

    var result = (await receivePort.first) as ActorSystemCreateConnectorResult;

    receivePort.close();

    if (result is ActorSystemCreateConnectorSuccess) {
      return result.connection;
    } else {
      throw OutgoingConnectionException(
          message:
              'actor system server has outgoing connection with name ${configuration.name}.');
    }
  }

  ///
  Future<void> createServer(ServerConfiguration configuration) async {
    var receivePort = ReceivePort();

    _actorProperties.actorSystemSendPort
        .send(ActorSystemCreateServer(configuration, receivePort.sendPort));

    var result = (await receivePort.first) as ActorSystemCreateServerResult;

    receivePort.close();

    if (result is! ActorSystemCreateServerSuccess) {
      throw ServerException(
          message:
              'actor system server has server with name ${configuration.name}.');
    }
  }
}
