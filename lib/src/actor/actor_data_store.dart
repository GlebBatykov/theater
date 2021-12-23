part of theater.actor;

/// Stores the data transferred to the actor when it is created.
class ActorDataStore {
  final Map<String, dynamic> _data;

  ActorDataStore(Map<String, dynamic> data) : _data = data;

  /// Check if exist instance with name [instanceName] in store.
  bool isExist(String instanceName) {
    return _data.keys.contains(instanceName);
  }

  /// Get instanse of type [T] by name [instanceName].
  ///
  /// If instanse is not exist in store an exception will be thrown.
  T get<T>(String instanceName) {
    return _data[instanceName] as T;
  }

  /// Get instanse of type [T] by name [instanceName].
  ///
  /// If instanse is not exist return null.
  T? tryGet<T>(String instanceName) {
    var object = _data[instanceName];

    return object != null ? object as T : object;
  }
}
