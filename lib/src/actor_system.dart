library theater.actor_system;

import 'dart:async';
import 'dart:isolate';

import 'package:theater/src/system_actors.dart';

import 'actor.dart';
import 'dispatch.dart';
import 'remote.dart';
import 'routing.dart';

part 'actor_system/actor_system.dart';
part 'actor_system/action/actor_system_action.dart';

part 'actor_system/builder/actor_system_builder.dart';
part 'actor_system/builder/actor_system_async_builder.dart';

part 'actor_system/event/actor_system_event.dart';
part 'actor_system/event/actor_system_create_remote_actor_ref_result.dart';

part 'actor_system/action/actor_system_get_local_actor_ref.dart';
part 'actor_system/action/actor_system_is_exist_local_actor_ref.dart';
part 'actor_system/action/actor_system_register_local_actor_ref.dart';
part 'actor_system/action/actor_system_remove_local_actor_ref.dart';
