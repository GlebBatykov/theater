part of theater.remote;

class TransportMessage {
  final String type;

  final String data;

  TransportMessage(this.type, this.data);

  TransportMessage.invalidAuthorization()
      : type = RemoteMessageType.invalidAuthorization,
        data = '';

  TransportMessage.successAuthorization()
      : type = RemoteMessageType.successAuthorization,
        data = '';

  TransportMessage.login(String key)
      : type = RemoteMessageType.login,
        data = RemoteTransportEventSerializer.serialize(LoginEvent(key));

  TransportMessage.actorMessage(ActorPath path, String tag, String data)
      : type = RemoteMessageType.actorMessage,
        data = RemoteTransportEventSerializer.serialize(
            ActorMessageEvent(path, tag, data));

  TransportMessage.systemMessage()
      : type = RemoteMessageType.systemMessage,
        data = '';

  TransportMessage.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        data = json['data'];

  Map<String, dynamic> toJson() => {'type': type, 'data': data};
}
