part of theater.routing;

class ActorPathJsonSerializer {
  Map<String, dynamic> serialize(ActorPath path) => {
        'systemName': path.systemName,
        'name': path.name,
        'segments': path.segments,
        'parentPath':
            path.parentPath != null ? serialize(path.parentPath!) : null,
        'depthLevel': path.depthLevel
      };
}
