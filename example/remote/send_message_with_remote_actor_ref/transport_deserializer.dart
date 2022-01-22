import 'dart:convert';

import 'package:theater/theater.dart';

import 'message.dart';

// Create deserializer class
class TransportDeserializer extends ActorMessageTransportDeserializer {
  // Override deserialize method
  @override
  dynamic deserialize(String tag, String data) {
    if (tag == 'test_message') {
      return Message.fromJson(jsonDecode(data));
    } else {
      return data;
    }
  }
}
