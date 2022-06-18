part of theater.remote;

class GetActorsPathsResult extends SystemMessageEvent {
  final int id;

  final List<ActorPath> paths;

  GetActorsPathsResult(this.id, this.paths);

  GetActorsPathsResult.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        paths = List.of(json['paths'])
            .map((e) => ActorPathJsonDeserializer().deserialize(e))
            .toList();

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paths': paths.map((e) => ActorPathJsonSerializer().serialize(e)).toList()
    };
  }
}
