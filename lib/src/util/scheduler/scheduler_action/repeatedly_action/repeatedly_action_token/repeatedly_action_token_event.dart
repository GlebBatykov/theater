part of theater.util;

abstract class RepeatedlyActionTokenEvent {}

class RepeatedlyActionTokenStop extends RepeatedlyActionTokenEvent {}

class RepeatedlyActionTokenResume extends RepeatedlyActionTokenEvent {}

class RepeatedlyActionTokenGetStatus extends RepeatedlyActionTokenEvent {
  final SendPort feedbackPort;

  RepeatedlyActionTokenGetStatus(this.feedbackPort);
}

class RepeatedlyActionTokenStatus extends RepeatedlyActionTokenEvent {
  final RepeatedlyActionStatus status;

  RepeatedlyActionTokenStatus(this.status);
}
