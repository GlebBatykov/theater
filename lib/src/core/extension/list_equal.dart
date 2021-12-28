part of theater.core;

extension ListEqualExtension on List {
  bool equal(List other) {
    if (other.length != length) {
      return false;
    } else {
      for (var i = 0; i < length; i++) {
        if (this[i] is List && other[i] is List) {
          if (!(this[i] as List).equal(other[i])) {
            return false;
          }
        } else {
          if (this[i] != other[i]) {
            return false;
          }
        }
      }
    }

    return true;
  }
}
