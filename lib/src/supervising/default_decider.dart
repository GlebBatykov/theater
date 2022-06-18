part of theater.supervising;

class DefaultDecider extends Decider {
  @override
  Directive decide(Object object) {
    return EscalateDirective();
  }
}
