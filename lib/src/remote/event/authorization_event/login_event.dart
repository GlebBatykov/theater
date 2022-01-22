part of theater.remote;

class LoginEvent extends AuthorizationEvent {
  final String key;

  LoginEvent(this.key);

  LoginEvent.fromJson(Map<String, dynamic> json) : key = json['key'];

  @override
  Map<String, dynamic> toJson() => {'key': key};
}
