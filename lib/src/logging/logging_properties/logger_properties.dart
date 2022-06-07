part of theater.logging;

class LoggingProperties {
  final LoggerFactory loggerFactory;

  final List<LogLevel> enabled;

  late final DebugLevel? debug;

  late final bool isInfoEnabled;

  bool get isDebugEnabled => debug != null;

  LoggingProperties({List<LogLevel>? enabled, required this.loggerFactory})
      : enabled = enabled ?? [LogLevel.info] {
    isInfoEnabled = this.enabled.contains(LogLevel.info);

    _setDebugLevel(this.enabled);
  }

  void _setDebugLevel(List<LogLevel> levels) {
    var isDebugInitialized = false;

    for (var level in levels) {
      if (level is DebugLevel) {
        debug = level;
        isDebugInitialized = true;
        break;
      } else if (level == LogLevel.debug) {
        debug = DebugLevel(lifecycle: true);
        isDebugInitialized = true;
        break;
      }
    }

    if (!isDebugInitialized) {
      debug = null;
    }
  }
}
