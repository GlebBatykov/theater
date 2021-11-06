part of theater.actor;

class DefaultDecider extends Decider {
  @override
  Directive decide(Exception exception) {
    return Directive.escalate;
  }
}
