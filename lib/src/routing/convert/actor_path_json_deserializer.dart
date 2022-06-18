part of theater.routing;

class ActorPathJsonDeserializer {
  ActorPath deserialize(Map<String, dynamic> json) {
    late ActorPath path;

    var segments = List.of(json['segments']).map((e) => e.toString()).toList();

    var systemName = json['systemName'] as String;

    var depthLevel = json['depthLevel'] as int;

    if (segments.length > 1) {
      var name = segments.removeLast();

      var parent = ActorPath(systemName, segments.removeAt(0), 0);

      while (segments.isNotEmpty) {
        parent = ActorPath.withParent(parent, segments.removeAt(0));
      }

      path = ActorPath.withParent(parent, name);
    } else {
      path = ActorPath(systemName, segments[0], depthLevel);
    }

    return path;
  }
}
