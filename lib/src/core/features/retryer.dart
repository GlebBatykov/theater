part of theater.core;

class Retryer {
  final Duration _duration;

  final double _delay;

  final double _damping;

  Retryer(
      {required Duration duration, double delay = 100, double damping = 0.25})
      : _duration = duration,
        _delay = delay,
        _damping = damping;

  Future<void> execute(Future<void> Function() action) async {
    var endTime = DateTime.now().add(_duration);

    var delay = 0.0;

    while (true) {
      try {
        return await action();
      } catch (object) {
        if (DateTime.now()
                .add(Duration(milliseconds: delay.toInt()))
                .isBefore(endTime) &&
            DateTime.now().isBefore(endTime)) {
          if (delay == 0) {
            delay = _delay;
          } else {
            delay += delay * _damping;
          }

          await Future.delayed(Duration(milliseconds: delay.toInt()));
        } else {
          rethrow;
        }
      }
    }
  }
}
