library theater.remote;

import 'package:theater/src/routing.dart';

part 'remote/serialization/actor_message_transport_deserializator.dart';
part 'remote/serialization/actor_message_transport_serializator.dart';
part 'remote/serialization/authorization_transport_deserializator.dart';
part 'remote/serialization/authorization_transport_serializator.dart';
part 'remote/serialization/system_message_transport_deserializator.dart';
part 'remote/serialization/system_message_transport_serializator.dart';

part 'remote/remote_message.dart';
part 'remote/remote_transport_configuration.dart';
part 'remote/server_configuration.dart';

part 'remote/event/remote_transport_event.dart';
part 'remote/event/message_event.dart';
part 'remote/event/actor_message_event.dart';
part 'remote/event/system_message_event.dart';
part 'remote/event/authorization_event/authorization_event.dart';
part 'remote/event/authorization_event/login_event.dart';
part 'remote/event/authorization_event/invalid_authorization_event.dart';

part 'remote/server/server.dart';
part 'remote/server/tcp_server.dart';
