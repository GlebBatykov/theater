import 'dart:isolate';

import 'package:async/async.dart';
import 'package:theater/src/actor.dart';

class ActorCellTestData<T extends ActorCell> {
  final T actorCell;

  final ReceivePort receivePort;

  final StreamQueue streamQueue;

  ActorCellTestData(this.actorCell, this.receivePort, this.streamQueue);
}
