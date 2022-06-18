import 'actor/actor_cell_test.dart' as actor_cell_test;
import 'actor/actor_context_test.dart' as actor_context_test;
import 'actor/actor_system_test.dart' as actor_system_test;
import 'actor/isolate_test.dart' as isolate_test;
import 'dispatch/dispatch_test.dart' as dispatch_test;
import 'routing/routing_test.dart' as routing_test;
import 'util/util_test.dart' as util_test;
import 'remote/remote_test.dart' as remote_test;
import 'logging/logging_test.dart' as logging_test;

void main() {
  actor_cell_test.main();
  actor_context_test.main();
  actor_system_test.main();
  isolate_test.main();
  dispatch_test.main();
  routing_test.main();
  util_test.main();
  remote_test.main();
  logging_test.main();
}
