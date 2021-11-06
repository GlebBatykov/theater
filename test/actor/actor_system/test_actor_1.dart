import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';

class TestActor_1 extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    context.receive<String>((message) async {
      if (message == 'ping') {
        return MessageResult(data: 'pong');
      }
    });
  }
}
