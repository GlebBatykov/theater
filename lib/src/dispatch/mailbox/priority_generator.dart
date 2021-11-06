part of theater.dispatch;

/// Used in [PriorityReliableMailbox] for generate priority to messages.
abstract class PriorityGenerator {
  /// Generates priority to message.
  ///
  /// The larger the returned value, the higher the priority.
  int generatePriority(dynamic object);
}
