part of theater.remote;

///
class ConnectorSupervisingStrategy {
  final ConnectorDesider _desider;

  ConnectorSupervisingStrategy({required ConnectorDesider desider})
      : _desider = desider;

  ///
  ConnectorDirective deside(ConnectorError error) {
    return _desider.decide(error);
  }
}
