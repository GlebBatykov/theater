part of theater.remote;

abstract class RemoteMessageType {
  static const String invalidAuthorization = 'invalid_authorization';

  static const String successAuthorization = 'success_authorization';

  static const String login = 'login';

  static const String actorMessage = 'actor_message';

  static const String getActorsPaths = 'get_actors_paths';

  static const String getActorsPathsResult = 'get_actors_paths_result';
}
