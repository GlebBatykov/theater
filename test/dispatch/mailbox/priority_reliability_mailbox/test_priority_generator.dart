import 'package:theater/src/dispatch.dart';

class TestPriorityGenerator_1 extends PriorityGenerator {
  @override
  int generatePriority(object) {
    if (object is String) {
      return 2;
    } else if (object is int) {
      return 1;
    } else {
      return 0;
    }
  }
}
