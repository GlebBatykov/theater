part of theater.remote;

///
class ConnectorDefaultDecider extends ConnectorDesider {
  @override
  ConnectorDirective decide(ConnectorError error) {
    return ConnectorEscalateDirective();
  }
}
