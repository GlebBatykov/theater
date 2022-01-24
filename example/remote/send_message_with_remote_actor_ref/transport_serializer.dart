import 'dart:convert';

import 'package:theater/theater.dart';

import 'test_message.dart';

// Create serializer class
class TransportSerializer extends ActorMessageTransportSerializer {
  // Override serialize method
  @override
  String serialize(String tag, dynamic data) {
    if (data is TestMessage) {
      return jsonEncode(data.toJson());
    } else {
      return data.toString();
    }
  }
}
