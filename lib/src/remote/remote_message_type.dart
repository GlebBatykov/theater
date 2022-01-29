part of theater.remote;

abstract class RemoteMessageType {
  static const String invalidAuthorization = 'invalid_authorization';

  static const String successAuthorization = 'success_authorization';

  static const String login = 'login';

  static const String actorMessage = 'actor_message';

  static const String systemMessage = 'system_message';
}
