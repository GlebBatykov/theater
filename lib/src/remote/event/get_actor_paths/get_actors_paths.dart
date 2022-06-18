part of theater.remote;

class GetActorsPaths extends SystemMessageEvent {
  final int id;

  GetActorsPaths(this.id);

  GetActorsPaths.fromJson(Map<String, dynamic> json) : id = json['id'];

  @override
  Map<String, dynamic> toJson() => {'id': id};
}
