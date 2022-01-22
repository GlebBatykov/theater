part of theater.remote;

class ActorMessageEvent extends MessageEvent {
  final ActorPath path;

  final String tag;

  final String data;

  ActorMessageEvent(this.path, this.tag, this.data);

  ActorMessageEvent.fromJson(Map<String, dynamic> json)
      : path = ActorPath.parceAbsolute(json['path']),
        tag = json['tag'],
        data = json['data'];

  @override
  Map<String, dynamic> toJson() =>
      {'path': path.toString(), 'tag': tag, 'data': data};
}
