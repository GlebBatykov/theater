import 'package:theater/theater.dart';

class TestActor_3 extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    context.sendToTopic('test_topic', 'test');
  }
}
