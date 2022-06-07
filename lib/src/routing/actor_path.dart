part of theater.routing;

/// Used to represent the path to actor in actors tree.
class ActorPath {
  /// Actor system name.
  final String systemName;

  /// The path to the parent of the current actor.
  ///
  /// Equal to null only for root actor.
  final ActorPath? parentPath;

  /// Name of current actor.
  late final String name;

  /// Displays the depth level in the actor tree relative to the root actor.
  ///
  /// Root actor has zero depth level.
  final int depthLevel;

  /// The current path without [Address], divided into segments with '/' delimiter.
  final List<String> segments;

  ActorPath(this.systemName, String name, this.depthLevel)
      : parentPath = null,
        segments = [name] {
    if (name.contains('/')) {
      throw ActorPathException(message: 'name must not contain "/".');
    } else {
      this.name = name;
    }
  }

  /// Creates actor path using [parentPath].
  ActorPath.withParent(ActorPath parentPath, String name)
      : parentPath = parentPath,
        systemName = parentPath.systemName,
        depthLevel = parentPath.depthLevel + 1,
        segments = List.from(parentPath.segments)..add(name) {
    if (name.contains('/')) {
      throw ActorPathException(message: 'name must not contain "/".');
    } else {
      this.name = name;
    }
  }

  /// Creates actor path trying parce [path] like absolute path.
  ///
  /// Absolute path should start from [ActorSystem] name.
  factory ActorPath.parceAbsolute(String path) {
    var pathSegments =
        path.split('/').where((element) => element.isNotEmpty).toList();

    if (pathSegments.isNotEmpty) {
      var systemName = pathSegments.removeAt(0);

      var actorPath = ActorPath(systemName, pathSegments.removeAt(0), 0);

      for (var segment in pathSegments) {
        actorPath = actorPath.createChild(segment);
      }

      return actorPath;
    } else {
      throw ActorPathException(message: 'path must not be empty.');
    }
  }

  /// Creates actor path trying parce [path] like relative path.
  ///
  /// Relative path should start from '../'.
  ///
  /// Relative path indicated from [currentPath].
  ///
  /// For example
  factory ActorPath.parceRelative(String path, ActorPath currentPath) {
    if (isRelativePath(path)) {
      var pathSegments = path.split('/')..removeAt(0);

      var actorPath = currentPath;

      for (var segment in pathSegments) {
        actorPath = actorPath.createChild(segment);
      }

      return actorPath;
    } else {
      throw ActorPathException(message: 'relative path must start with "..".');
    }
  }

  /// Creates actor path using as parent path this path.
  ActorPath createChild(String name) => ActorPath.withParent(this, name);

  /// Checks [path] is it relative path.
  static bool isRelativePath(String path) {
    var pathSegments = path.split('/');

    if (pathSegments.isNotEmpty) {
      if (pathSegments.first == '..') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  String toString() {
    if (parentPath != null) {
      return parentPath!.toString() + '/' + name;
    } else {
      return systemName + '/' + name;
    }
  }

  @override
  bool operator ==(other) {
    if (other is ActorPath) {
      return toString() == other.toString();
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    var hashCode = super.hashCode;

    return hashCode;
  }
}
