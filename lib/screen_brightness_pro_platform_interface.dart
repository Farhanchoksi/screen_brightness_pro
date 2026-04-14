import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'screen_brightness_pro_method_channel.dart';

abstract class ScreenBrightnessProPlatform extends PlatformInterface {
  /// Constructs a ScreenBrightnessProPlatform.
  ScreenBrightnessProPlatform() : super(token: _token);

  static final Object _token = Object();

  static ScreenBrightnessProPlatform _instance = MethodChannelScreenBrightnessPro();

  /// The default instance of [ScreenBrightnessProPlatform] to use.
  ///
  /// Defaults to [MethodChannelScreenBrightnessPro].
  static ScreenBrightnessProPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ScreenBrightnessProPlatform] when
  /// they register themselves.
  static set instance(ScreenBrightnessProPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the current screen brightness as a value between 0.0 and 1.0.
  Future<double?> getBrightness() {
    throw UnimplementedError('getBrightness() has not been implemented.');
  }

  /// Sets the screen brightness.
  /// [brightness] must be between 0.0 and 1.0.
  Future<void> setBrightness(double brightness) {
    throw UnimplementedError('setBrightness() has not been implemented.');
  }

  /// Stream of brightness changes from the system.
  Stream<double> get onBrightnessChanged {
    throw UnimplementedError('onBrightnessChanged has not been implemented.');
  }

  /// Checks if auto-brightness (automatic mode) is enabled.
  Future<bool> isAutoModeEnabled() {
    throw UnimplementedError('isAutoModeEnabled() has not been implemented.');
  }

  /// Sets the auto-brightness mode.
  Future<void> setAutoMode(bool enabled) {
    throw UnimplementedError('setAutoMode() has not been implemented.');
  }

  /// Checks if the app has permission to write system settings (Android only).
  Future<bool> hasWriteSettingsPermission() {
    throw UnimplementedError('hasWriteSettingsPermission() has not been implemented.');
  }

  /// Requests permission to write system settings (Android only).
  Future<void> requestWriteSettingsPermission() {
    throw UnimplementedError('requestWriteSettingsPermission() has not been implemented.');
  }

  /// Resets the screen brightness to the system default.
  Future<void> resetBrightness() {
    throw UnimplementedError('resetBrightness() has not been implemented.');
  }

  /// Sets the global system brightness.
  Future<void> setSystemBrightness(double brightness) {
    throw UnimplementedError('setSystemBrightness() has not been implemented.');
  }

  /// Controls whether the screen should stay on (prevent sleeping).
  Future<void> setKeepScreenOn(bool enabled) {
    throw UnimplementedError('setKeepScreenOn() has not been implemented.');
  }

  /// Returns the current battery level as a value between 0.0 and 1.0.
  Future<double> getBatteryLevel() {
    throw UnimplementedError('getBatteryLevel() has not been implemented.');
  }

  /// Checks if the device is currently in low power mode (battery saver).
  Future<bool> isLowPowerModeEnabled() {
    throw UnimplementedError('isLowPowerModeEnabled() has not been implemented.');
  }
}
