// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing


import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:screen_brightness_pro/screen_brightness_pro.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('getBrightness test', (WidgetTester tester) async {
    final double brightness = await ScreenBrightnessPro.getBrightness();
    // Brightness should be between 0.0 and 1.0
    expect(brightness >= 0.0 && brightness <= 1.0, true);
  });
}
