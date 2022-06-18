part of theater.logging;

class ServerStartLog {
  final String name;

  ServerStartLog(this.name);

  @override
  String toString() {
    return 'Server with name: $name was started.';
  }
}
