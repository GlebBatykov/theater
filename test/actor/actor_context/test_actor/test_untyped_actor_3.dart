import 'dart:io';

import 'package:theater/src/actor.dart';
import 'package:theater/src/dispatch.dart';

class TestUntypedActor_3 extends UntypedActor {
  @override
  Future<void> onStart(context) async {
    context.receive<String>((message) async {
      sleep(Duration(milliseconds: 100));

      return MessageResult(data: message);
    });
  }
}
