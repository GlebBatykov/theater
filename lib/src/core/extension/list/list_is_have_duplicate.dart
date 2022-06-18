part of theater.core;

extension ListIsHaveDuplicate on List {
  bool get isHaveDuplicate {
    var isHaveDuplicate = false;

    if (isNotEmpty) {
      for (var i = 0; i < length; i++) {
        for (var j = i; j < length; j++) {
          if (i != j && this[i] == this[j]) {
            isHaveDuplicate = true;

            break;
          }
        }

        if (isHaveDuplicate) {
          break;
        }
      }
    }

    return isHaveDuplicate;
  }
}
