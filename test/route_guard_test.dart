import 'package:flutter_test/flutter_test.dart';
import 'package:proj/app/routes/route_guard.dart';

void main() {
  test(
    'farm selection is allowed while the user chooses a farm after splash',
    () {
      expect(RouteGuard.isPublic('/farm-selection'), isTrue);
    },
  );
}
