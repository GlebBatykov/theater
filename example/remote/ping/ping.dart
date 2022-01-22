import 'message.dart';

class Ping extends Message {
  Ping(String data) : super(data);

  Ping.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
