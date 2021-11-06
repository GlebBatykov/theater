import 'dart:io';

import 'package:theater/theater.dart';

// Create server receiver actor class
class ServerReceiver extends UntypedActor {
  // Override onStart method which will be executed at actor startup
  @override
  Future<void> onStart(UntypedActorContext context) async {
    print('Server actor with path: [' +
        context.path.toString() +
        '] is started!');

    // Create HttpServer with [shared: true] properties.
    // This is necessary to distribute the requests arriving on this port among all actors (isolates) listening on it.
    var server = await HttpServer.bind('127.0.0.1', 4467, shared: true);

    server.listen((request) async {
      print('Actor with path: ' +
          context.path.toString() +
          ', receive http request!');

      request.response.statusCode = 200;
      request.response.write('Hello, world!');
      await request.response.close();
    });
  }
}

void main(List<String> arguments) async {
  // Create actor system
  var actorSystem = ActorSystem('test_system');

  // Initialize actor system before work with her
  await actorSystem.initialize();

  for (var i = 0; i < 3; i++) {
    // Create receiver actor class
    await actorSystem.actorOf(
        'receiver-' + (i + 1).toString(), ServerReceiver());
  }
}
