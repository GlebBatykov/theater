part of theater.logging;

class LogLevel {
  final String value;

  static final LogLevel info = LogLevel._('info');

  static final LogLevel debug = LogLevel._('debug');

  static final LogLevel warning = LogLevel._('warning');

  static final LogLevel error = LogLevel._('error');

  static final LogLevel critical = LogLevel._('critical');

  LogLevel._(this.value);

  @override
  bool operator ==(other) {
    if (other is LogLevel) {
      return value == other.value;
    } else {
      return false;
    }
  }
}
