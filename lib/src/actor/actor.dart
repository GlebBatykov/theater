part of theater.actor;

/// Class is used for settings actors.
///
/// Class contains four methods which symbolize its life cycle:
///
/// [onStart] - method is called after actor started (after him [Isolate] started).
///
/// [onKill] - method is called before actor will killed (before him [Isolate] will killed).
///
/// [onPause] - method is called before actor will paused (before him [Isolate] will paused).
///
/// [onResume] - method is called after actor resumed (after him [Isolate] resumed).
///
/// All of the above methods return [Future]. Once [Future] completed actor sends successful event to him supervisor.
///
/// Therefore, it is important not to wait indefinitely for anything in these methods  asynchronously.
abstract class Actor<T extends ActorContext>
    implements
        MailboxFactoryCreater,
        SupervisorStrategyCreater,
        LoggingPropertiesCreater {
  /// This method is called after actor started (after him [Isolate] started).
  FutureOr<void> onStart(T context) async {}

  /// This method is called before actor will killed (before him [Isolate] will killed).
  FutureOr<void> onKill(T context) async {}

  /// This method is called before actor will paused (before him [Isolate] will paused).
  FutureOr<void> onPause(T context) async {}

  /// This method is called after actor resumed (after him [Isolate] resumed).
  FutureOr<void> onResume(T context) async {}

  /// Creates [MailboxFactory] which will be used to create [Mailbox] for actor.
  ///
  /// By default creates instanse of [UnreliableMailboxFactory].
  @override
  MailboxFactory createMailboxFactory() => UnreliableMailboxFactory();

  /// Creates [SupervisorStrategy] which the actor will use.
  ///
  /// By default creates instanse of [OneForOneStrategy] with [DefaultDecider].
  ///
  /// [DefaultDecider] - always return [Directive.escalate].
  @override
  SupervisorStrategy createSupervisorStrategy() =>
      OneForOneStrategy(decider: DefaultDecider());

  ///
  @override
  LoggingProperties? createLoggingPropeties() => null;
}
