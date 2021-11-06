import 'package:test/test.dart';
import 'package:theater/src/routing.dart';

void main() {
  group('actor_path', () {
    var address = Address('test_system');

    var parentPath = ActorPath(address, 'test', 0);

    test('.withParent(). ', () {
      var path = ActorPath.withParent(parentPath, 'test_child');

      expect(path.segments, ['test', 'test_child']);
      expect(path.toString(), 'tcp://test_system/test/test_child');
      expect(path.depthLevel, 1);
    });

    test('.parceAbsolute(). ', () {
      var path = ActorPath.parceAbsolute('test_system/test/test_child');

      expect(path.segments, ['test', 'test_child']);
      expect(path.toString(), 'tcp://test_system/test/test_child');
      expect(path.depthLevel, 1);
    });

    test('.parceRelative(). ', () {
      var path = ActorPath.parceRelative('../test_child', parentPath);

      expect(path.segments, ['test', 'test_child']);
      expect(path.toString(), 'tcp://test_system/test/test_child');
      expect(path.depthLevel, 1);
    });

    test('.createChild(). ', () {
      var path = parentPath.createChild('test_child');

      expect(path.segments, ['test', 'test_child']);
      expect(path.toString(), 'tcp://test_system/test/test_child');
      expect(path.depthLevel, 1);
    });

    test('.isRelativePath(). ', () {
      var isRelativePath = ActorPath.isRelativePath('../test_child');
      var isNotRelativePath = ActorPath.isRelativePath('/test_child');

      expect(isRelativePath, true);
      expect(isNotRelativePath, false);
    });

    test('.toString(). ', () {
      expect(parentPath.toString(), 'tcp://test_system/test');
    });
  });

  group('address', () {
    test('.toString(). ', () {
      var address = Address('test_system',
          protocol: 'udp', host: '127.0.0.1', port: 8555);

      expect(address.toString(), 'udp://test_system@127.0.0.1:8555');
    });
  });
}
