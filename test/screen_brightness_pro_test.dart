import 'package:flutter_test/flutter_test.dart';
import 'package:screen_brightness_pro/screen_brightness_pro.dart';
import 'package:screen_brightness_pro/screen_brightness_pro_platform_interface.dart';
import 'package:screen_brightness_pro/screen_brightness_pro_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockScreenBrightnessProPlatform
    with MockPlatformInterfaceMixin
    implements ScreenBrightnessProPlatform {

  @override
  Future<double?> getBrightness() => Future.value(0.5);

  @override
  Future<void> setBrightness(double value) => Future.value();

  @override
  Stream<double> get onBrightnessChanged => Stream.fromIterable([0.5, 0.6]);

  @override
  Future<bool> isAutoModeEnabled() => Future.value(false);

  @override
  Future<void> setAutoMode(bool enabled) => Future.value();

  @override
  Future<bool> hasWriteSettingsPermission() => Future.value(true);

  @override
  Future<void> requestWriteSettingsPermission() => Future.value();

  @override
  Future<void> resetBrightness() => Future.value();

  @override
  Future<void> setSystemBrightness(double value) => Future.value();

  @override
  Future<void> setKeepScreenOn(bool enabled) => Future.value();
}

void main() {
  final ScreenBrightnessProPlatform initialPlatform = ScreenBrightnessProPlatform.instance;

  test('$MethodChannelScreenBrightnessPro is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelScreenBrightnessPro>());
  });

  test('getBrightness', () async {
    MockScreenBrightnessProPlatform fakePlatform = MockScreenBrightnessProPlatform();
    ScreenBrightnessProPlatform.instance = fakePlatform;

    expect(await ScreenBrightnessPro.getBrightness(), 0.5);
  });
}
