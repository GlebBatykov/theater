import 'package:test/test.dart';
import 'package:theater/src/routing.dart';

void main() {
  group('actor_path', () {
    var address = 'test_system';

    var parentPath = ActorPath(address, 'test', 0);

    test('.withParent(). Creates actor path with actor parent.', () {
      var path = ActorPath.withParent(parentPath, 'test_child');

      expect(path.segments, ['test', 'test_child']);
      expect(path.toString(), 'test_system/test/test_child');
      expect(path.depthLevel, 1);
    });

    test(
        '.parceAbsolute(). Creates actor path from string which contains absolute path.',
        () {
      var path = ActorPath.parceAbsolute('test_system/test/test_child');

      expect(path.segments, ['test', 'test_child']);
      expect(path.toString(), 'test_system/test/test_child');
      expect(path.depthLevel, 1);
    });

    test(
        '.parceRelative(). Creates actor path from string whuck contains relative path.',
        () {
      var path = ActorPath.parceRelative('../test_child', parentPath);

      expect(path.segments, ['test', 'test_child']);
      expect(path.toString(), 'test_system/test/test_child');
      expect(path.depthLevel, 1);
    });

    test('.createChild(). Creates child path.', () {
      var path = parentPath.createChild('test_child');

      expect(path.segments, ['test', 'test_child']);
      expect(path.toString(), 'test_system/test/test_child');
      expect(path.depthLevel, 1);
    });

    test('.isRelativePath(). Checks if a string is a relative path.', () {
      var isRelativePath = ActorPath.isRelativePath('../test_child');
      var isNotRelativePath = ActorPath.isRelativePath('/test_child');

      expect(isRelativePath, true);
      expect(isNotRelativePath, false);
    });

    test('.toString(). Converts actor path to string and check it.', () {
      expect(parentPath.toString(), 'test_system/test');
    });
  });
}
