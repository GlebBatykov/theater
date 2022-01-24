// If you need create some class to use as a message
class TestMessage {
  final String data;

  TestMessage(this.data);

  TestMessage.fromJson(Map<String, dynamic> json) : data = json['data'];

  Map<String, dynamic> toJson() => {'data': data};
}
