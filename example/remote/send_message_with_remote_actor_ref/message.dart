// If you need create some class to use as a message
class Message {
  final String data;

  Message(this.data);

  Message.fromJson(Map<String, dynamic> json) : data = json['data'];

  Map<String, dynamic> toJson() => {'data': data};
}
