import 'package:test/scaffolding.dart';

void main() {
  group('server', () {
    group('tcp_server', () {});
  }, timeout: Timeout(Duration(seconds: 1)));

  group('connection', () {
    group('tcp_connection', () {});
  }, timeout: Timeout(Duration(seconds: 1)));

  group('connector', () {
    group('tcp_connector', () {});
  }, timeout: Timeout(Duration(seconds: 1)));
}
