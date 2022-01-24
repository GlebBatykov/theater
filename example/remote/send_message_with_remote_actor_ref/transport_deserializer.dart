import 'dart:convert';

import 'package:theater/theater.dart';

import 'test_message.dart';

// Create deserializer class
class TransportDeserializer extends ActorMessageTransportDeserializer {
  // Override deserialize method
  @override
  dynamic deserialize(String tag, String data) {
    if (tag == 'test_message') {
      return TestMessage.fromJson(jsonDecode(data));
    } else {
      return data;
    }
  }
}
