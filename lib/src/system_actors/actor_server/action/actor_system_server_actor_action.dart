part of theater.system_actors;

abstract class ActorSystemServerAction {}

class ActorSystemServerAddRemoteSource extends ActorSystemServerAction {
  final ConnectorSource remoteSource;

  ActorSystemServerAddRemoteSource(this.remoteSource);
}

class ActorSystemServerCreateConnector extends ActorSystemServerAction {
  final ConnectorConfiguration configuration;

  final SendPort feedbackPort;

  ActorSystemServerCreateConnector(this.configuration, this.feedbackPort);
}

class ActorSystemServerCreateServer extends ActorSystemServerAction {
  final ServerConfiguration configuration;

  final SendPort feedbackPort;

  ActorSystemServerCreateServer(this.configuration, this.feedbackPort);
}
