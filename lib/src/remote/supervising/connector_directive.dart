part of theater.remote;

///
abstract class ConnectorDirective {
  final String name;

  ConnectorDirective(this.name);
}

class ConnectorReconnectDirective extends ConnectorDirective {
  final Duration? delay;

  ConnectorReconnectDirective({this.delay}) : super('reconnect');
}

class ConnectorRemoveDirective extends ConnectorDirective {
  ConnectorRemoveDirective() : super('remove');
}

class ConnectorReplaceDirective extends ConnectorDirective {
  final ConnectorConfiguration configuration;

  ConnectorReplaceDirective({required this.configuration}) : super('replace');
}

class ConnectorEscalateDirective extends ConnectorDirective {
  ConnectorEscalateDirective() : super('escalate');
}
