/// A professional Flutter plugin for controlling screen brightness across 6 platforms.
library;

import 'dart:async';
import 'screen_brightness_pro_platform_interface.dart';

class ScreenBrightnessPro {
  /// Returns the current screen brightness as a value between 0.0 and 1.0.
  static Future<double> getBrightness() async {
    return await ScreenBrightnessProPlatform.instance.getBrightness() ?? 0.5;
  }

  /// Sets the screen brightness.
  ///
  /// [value] must be between 0.0 and 1.0.
  /// [smooth] if true, the brightness will change gradually over [duration].
  static Future<void> setBrightness(double value, {bool smooth = false, Duration duration = const Duration(milliseconds: 500)}) async {
    if (value < 0.0) value = 0.0;
    if (value > 1.0) value = 1.0;

    if (!smooth) {
      await ScreenBrightnessProPlatform.instance.setBrightness(value);
      return;
    }

    final current = await getBrightness();
    final steps = 20;
    final delay = duration.inMilliseconds ~/ steps;
    final delta = (value - current) / steps;

    for (var i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: delay));
      await ScreenBrightnessProPlatform.instance.setBrightness(current + (delta * i));
    }
  }

  /// Stream of brightness changes.
  static Stream<double> get onBrightnessChanged {
    return ScreenBrightnessProPlatform.instance.onBrightnessChanged;
  }

  /// Checks if auto-brightness (automatic mode) is enabled.
  static Future<bool> isAutoModeEnabled() async {
    return await ScreenBrightnessProPlatform.instance.isAutoModeEnabled();
  }

  /// Sets the auto-brightness mode.
  /// 
  /// On Android, this requires [WRITE_SETTINGS] permission.
  /// Use [hasWriteSettingsPermission] to check.
  static Future<void> setAutoMode(bool enabled) async {
    await ScreenBrightnessProPlatform.instance.setAutoMode(enabled);
  }

  /// Checks if the app has permission to write system settings (Android only).
  /// Always returns true on iOS.
  static Future<bool> hasWriteSettingsPermission() async {
    return await ScreenBrightnessProPlatform.instance.hasWriteSettingsPermission();
  }

  /// Requests permission to write system settings (Android only).
  /// Opens the system settings page for the app.
  static Future<void> requestWriteSettingsPermission() async {
    await ScreenBrightnessProPlatform.instance.requestWriteSettingsPermission();
  }

  /// Resets the screen brightness to the system default.
  /// 
  /// On Android, this clears the window-level override.
  static Future<void> resetBrightness() async {
    await ScreenBrightnessProPlatform.instance.resetBrightness();
  }

  /// Sets the global system brightness.
  /// 
  /// On Android, this requires [WRITE_SETTINGS] permission.
  /// [value] must be between 0.0 and 1.0.
  static Future<void> setSystemBrightness(double value) async {
    if (value < 0.0) value = 0.0;
    if (value > 1.0) value = 1.0;
    await ScreenBrightnessProPlatform.instance.setSystemBrightness(value);
  }

  /// Controls whether the screen should stay on (prevent sleeping).
  static Future<void> setKeepScreenOn(bool enabled) async {
    await ScreenBrightnessProPlatform.instance.setKeepScreenOn(enabled);
  }

  /// Returns the current battery level as a value between 0.0 and 1.0.
  /// Returns -1.0 if the battery level cannot be determined.
  static Future<double> getBatteryLevel() async {
    return await ScreenBrightnessProPlatform.instance.getBatteryLevel();
  }

  /// Checks if the device is currently in low power mode (battery saver).
  static Future<bool> isLowPowerModeEnabled() async {
    return await ScreenBrightnessProPlatform.instance.isLowPowerModeEnabled();
  }

  /// Automatically adjusts brightness to a lower level if battery is low or power mode is on.
  ///
  /// [threshold] is the battery level (0.0 - 1.0) below which optimization kicks in.
  /// [targetBrightness] is the level to set if conditions are met.
  static Future<void> optimizeForLowBattery({double threshold = 0.2, double targetBrightness = 0.2}) async {
    final level = await getBatteryLevel();
    final isLowPower = await isLowPowerModeEnabled();

    if ((level >= 0.0 && level <= threshold) || isLowPower) {
      await setBrightness(targetBrightness, smooth: true);
    }
  }
}
