import 'dart:convert';

import 'package:theater/theater.dart';

import 'ping.dart';
import 'pong.dart';

// Create deserializer class
class TransportDeserializer extends ActorMessageTransportDeserializer {
  // Override deserialize method
  @override
  dynamic deserialize(String tag, String data) {
    if (tag == 'ping') {
      return Ping.fromJson(jsonDecode(data));
    } else if (tag == 'pong') {
      return Pong.fromJson(jsonDecode(data));
    } else {
      return data;
    }
  }
}
