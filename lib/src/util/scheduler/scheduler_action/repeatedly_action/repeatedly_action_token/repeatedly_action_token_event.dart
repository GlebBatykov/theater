part of theater.util;

abstract class RepeatedlyActionTokenEvent {}

class RepeatedlyActionTokenStop extends RepeatedlyActionTokenEvent {}

class RepeatedlyActionTokenResume extends RepeatedlyActionTokenEvent {}

class RepeatedlyActionTokenChangeInterval extends RepeatedlyActionTokenEvent {
  final Duration interval;

  RepeatedlyActionTokenChangeInterval(this.interval);
}

class RepeatedlyActionTokenGetStatus extends RepeatedlyActionTokenEvent {
  final SendPort feedbackPort;

  RepeatedlyActionTokenGetStatus(this.feedbackPort);
}

class RepeatedlyActionTokenStatus extends RepeatedlyActionTokenEvent {
  final RepeatedlyActionStatus status;

  RepeatedlyActionTokenStatus(this.status);
}
