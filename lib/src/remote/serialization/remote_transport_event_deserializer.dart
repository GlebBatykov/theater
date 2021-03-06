part of theater.remote;

abstract class RemoteTransportEventDeserializer {
  static RemoteTransportEvent deserialize(String type, String data) {
    late RemoteTransportEvent event;

    if (type == RemoteMessageType.invalidAuthorization) {
      event = InvalidAuthorizationEvent();
    } else if (type == RemoteMessageType.successAuthorization) {
      event = SuccessAuthorizationEvent();
    } else if (type == RemoteMessageType.actorMessage) {
      event = ActorMessageEvent.fromJson(jsonDecode(data));
    } else if (type == RemoteMessageType.systemMessage) {
      event = SystemMessageEvent();
    } else if (type == RemoteMessageType.login) {
      event = LoginEvent.fromJson(jsonDecode(data));
    }

    return event;
  }
}
