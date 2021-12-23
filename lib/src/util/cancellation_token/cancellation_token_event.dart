part of theater.util;

/// Event used for remote (from other isolate) cancellation in cancellation tokens.
abstract class CancellationTokenEvent {}

class RemoteCancelToken extends CancellationTokenEvent {}

class GetTokenStatus extends CancellationTokenEvent {
  final SendPort feedbackPort;

  GetTokenStatus(this.feedbackPort);
}

class TokenStatus extends CancellationTokenEvent {
  final bool status;

  TokenStatus(this.status);
}
