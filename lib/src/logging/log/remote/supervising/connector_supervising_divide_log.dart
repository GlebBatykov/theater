import 'package:theater/src/remote.dart';

class ConnectorSupervisingDivideLog {
  final String name;

  final ConnectorDirective directive;

  final ConnectorError error;

  ConnectorSupervisingDivideLog(this.name, this.directive, this.error);

  @override
  String toString() {
    return 'Connector name: $name, error: $error, directive: $directive.';
  }
}
