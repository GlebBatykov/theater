import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';

class TestUntypedActor_1 extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    context.receive<String>((message) async {
      return MessageResult(data: message);
    });
  }
}
