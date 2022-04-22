import 'package:flutter_theater_example_application/fibonacci.dart';
import 'package:theater/theater.dart';

// Create actor class
class TestActor extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  void onStart(UntypedActorContext context) {
    // Set handler to all int type messages which actor received
    context.receive<int>((message) async {
      // Calculate result
      var result = Fibonacci.calculate(message);

      // Send message result
      return MessageResult(data: result);
    });
  }
}
