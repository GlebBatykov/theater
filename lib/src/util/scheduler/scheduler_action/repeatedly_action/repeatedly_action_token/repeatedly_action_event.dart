part of theater.util;

abstract class RepeatedlyActionEvent extends SchedulerActionEvent {}

class RepeatedlyActionStop extends RepeatedlyActionEvent {}

class RepeatedlyActionResume extends RepeatedlyActionEvent {}

class RepeatedlyActionChangeInterval extends RepeatedlyActionEvent {
  final Duration interval;

  RepeatedlyActionChangeInterval(this.interval);
}
