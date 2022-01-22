import 'message.dart';

class Pong extends Message {
  Pong(String data) : super(data);

  Pong.fromJson(Map<String, dynamic> json) : super.fromJson(json);
}
