part of theater.system_actors;

class IndexStore {
  final List<int> _indexes = [];

  List<int> get indexes => List.unmodifiable(_indexes);

  int getNext() {
    int? index;

    if (_indexes.isNotEmpty) {
      for (var i = 0; i < _indexes.length; i++) {
        if (_indexes.length > 1) {
          if (i < _indexes.length - 1 &&
              _isTooDifferent(_indexes[i], _indexes[i + 1])) {
            index = _indexes[i] + 1;

            _indexes.insert(i + 1, index);

            break;
          }
        } else {
          var value = (i + 1);

          if (_indexes[i] == value) {
            index = value + 1;

            _indexes.add(index);

            break;
          } else {
            index = value;

            if (_indexes[i] < index) {
              _indexes.insert(i + 1, index);
            } else {
              _indexes.insert(i, index);
            }
          }
        }
      }
    } else {
      index = 1;

      _indexes.add(index);
    }

    if (index == null) {
      index = _indexes.last + 1;

      _indexes.insert(_indexes.length, index);
    }

    return index;
  }

  bool _isTooDifferent(int first, int second) {
    return (first - second).abs() > 1;
  }

  void remove(int value) {
    _indexes.remove(value);
  }
}
