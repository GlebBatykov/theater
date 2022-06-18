part of theater.logging;

class ConnectorLyfecycleLog {
  final String name;

  final ConnectorLyfecycleLogEvent event;

  ConnectorLyfecycleLog(this.name, this.event);

  @override
  String toString() {
    return 'Connector with name: $name, was ${event.name}';
  }
}
